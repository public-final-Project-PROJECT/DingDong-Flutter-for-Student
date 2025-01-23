import 'dart:convert';
import 'dart:math';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import '../model/calendar_model.dart';
import 'calendar_details.dart';

class HomeContent extends StatefulWidget {
  final String schoolName;

  const HomeContent({
    required this.schoolName,
    super.key,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  CalendarFormat format = CalendarFormat.month;
  final CalendarModel _calendarModel = CalendarModel();
  DateTime? _selectedDay = DateTime.now();
  DateTime? _focusedDay = DateTime.now();
  DateTime? _rangeStart = DateTime.now();
  DateTime? _rangeEnd = DateTime.now();
  String? schoolName;
  String apiKey = dotenv.get("FETCH_NEIS_API_KEY");
  String? atptOfcdcScCode;
  String? sdSchulCode;
  final Map<DateTime, List<dynamic>> _events = {};
  final random = Random();
  final List<Color> colors = [
    Colors.orangeAccent.shade100,
  ];
  bool _isMealLoaded = true; // 급식 정보 로드 상태
  bool _isTimetableLoaded = true; // 시간표 로드 상태
  String? mealDate;
  String? mealMenu;
  List<String> timetable = [
    '월요일',
    '국어',
    '수학',
    '영어',
    '과학',
    '체육',
    '역사',
    '음악',
    '미술',
  ];

  Future<void> fetchSchoolCodes() async {
    const String apiUrl = 'https://open.neis.go.kr/hub/schoolInfo';

    final params = {
      'KEY': apiKey,
      'Type': 'json',
      'SCHUL_NM': schoolName,
    };

    try {
      final uri = Uri.parse(apiUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final schoolData = data['schoolInfo']?[1]['row']?.first;
        if (schoolData != null) {
          atptOfcdcScCode = schoolData['ATPT_OFCDC_SC_CODE'];
          sdSchulCode = schoolData['SD_SCHUL_CODE'];
        } else {
          throw Exception('School not found in response');
        }
      } else {
        throw Exception(
            'Failed to fetch school info: HTTP ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error fetching school codes: $error');
    }

    await fetchSchoolMealInfo(apiKey, DateTime.now());
  }

  Future<void> fetchSchoolMealInfo(String apiKey, DateTime selectedDay) async {
    const String apiUrl = 'https://open.neis.go.kr/hub/mealServiceDietInfo';
    final targetDate = DateFormat('yyyyMMdd').format(selectedDay);
    final params = {
      'KEY': apiKey,
      'Type': 'json',
      'pIndex': '1',
      'pSize': '100',
      'ATPT_OFCDC_SC_CODE': atptOfcdcScCode!,
      'SD_SCHUL_CODE': sdSchulCode!,
      'MLSV_YMD': targetDate,
      'MLSV_TO_YMD': targetDate,
    };

    try {
      final uri = Uri.parse(apiUrl).replace(queryParameters: params);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final mealData = data['mealServiceDietInfo']?[1]['row']?.first;
        setState(() {
          mealDate = mealData != null ? mealData['MLSV_YMD'] : null;
          mealMenu =
              mealData != null ? cleanMealData(mealData['DDISH_NM']) : null;
          _isMealLoaded = true; // 급식 정보 로드 완료
        });

        if (mealData == null) {
          throw Exception('Meal data not found');
        }
      } else {
        throw Exception(
            'Failed to fetch meal info: HTTP ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('오늘 급식쉬는날이라 이래 : $error');
    }
  }

  String cleanMealData(String mealData) {
    return mealData
        .replaceAll('<br/>', ', ')
        .replaceAll(RegExp(r'[^가-힣a-zA-Z, ]'), '');
  }

  Future<void> _loadCalendar() async {
    try {
      final calendarData = await _calendarModel.calendarList();
      setState(() {
        _events.clear();
        for (final item in calendarData) {
          final startDate = DateTime.parse(item['start'])
              .add(const Duration(hours: 9))
              .toUtc();
          final endDate =
              DateTime.parse(item['end']).add(const Duration(hours: 9)).toUtc();

          for (var date = startDate;
              !date.isAfter(endDate);
              date = date.add(const Duration(days: 1))) {
            _events.putIfAbsent(date, () => []).add(item);
          }
        }
      });
    } catch (error) {
      throw Exception('Error loading calendar: $error');
    }
  }

  Future<void> _deleteEvent(int id) async {
    try {
      await _calendarModel.calendarDelete(id);
      await _loadCalendar();
    } catch (error) {
      throw Exception('Error deleting event: $error');
    }
  }

  Future<void> _updateEvent(dynamic event) async {
    try {
      await _calendarModel.calendarUpdate(event);
      await _loadCalendar();
    } catch (error) {
      throw Exception('Error updating event: $error');
    }
  }

  List<dynamic> _getEventsForRange(DateTime? start, DateTime? end) {
    if (start == null) return [];

    end ??= start;
    final events = <dynamic>[];

    for (var date = start;
        !date.isAfter(end);
        date = date.add(const Duration(days: 1))) {
      if (_events.containsKey(date)) {
        events.addAll(_events[date]!);
      }
    }

    return events;
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  String formatMealDate(String mealDate) {
    // 년, 월, 일을 각각 추출
    String year = mealDate.substring(0, 4); // 연도
    String month = mealDate.substring(4, 6); // 월
    String day = mealDate.substring(6, 8); // 일

    // 월과 일을 원하는 형식으로 변환
    String formattedMonth = '${int.parse(month)}월';
    String formattedDay = '${int.parse(day)}일';

    // 최종 결과
    return '$formattedMonth $formattedDay'; // 예: 11월 11일
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Positioned(
      right: 3,
      bottom: 3,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF9BB8D5),
        ),
        width: 12.0,
        height: 12.0,
        child: Center(
          child: Text(
            '${events.length}',
            style: const TextStyle(
              fontFamily: "NamuL",
              color: Colors.white,
              fontSize: 8.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget body() {
    return Container(
      constraints: const BoxConstraints.expand(), // 전체 화면 크기로 설정
      child: Column(
        children: [
          TableCalendar(
            key: ValueKey(_focusedDay?.month),
            firstDay: DateTime(2021, 10, 16),
            lastDay: DateTime(2030, 3, 14),
            locale: 'ko_KR',
            eventLoader: _getEventsForDay,
            calendarFormat: CalendarFormat.week,
            focusedDay: _focusedDay ?? DateTime.now(),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeStart,
            selectedDayPredicate: (day) =>
                _selectedDay != null && isSameDay(_selectedDay, day),
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = selectedDay;
                _rangeStart = selectedDay;
                _rangeEnd = selectedDay;
                _isMealLoaded = false; // 급식 정보 초기화
                _isTimetableLoaded = false; // 시간표 초기화
              });
              fetchSchoolMealInfo(apiKey, selectedDay);
              int weekday = selectedDay.weekday;
              fetchWeekdayInfo(weekday);
            },
            availableGestures: AvailableGestures.horizontalSwipe,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextFormatter: (date, locale) =>
                  DateFormat.yMMMMd(locale).format(date),

              titleTextStyle: TextStyle(
                fontFamily: "NamuL",
                fontSize: 22.0, // 제목 폰트 크기
                fontWeight: FontWeight.bold, // 제목 폰트 굵기
                color: Colors.orangeAccent, // 제목 색상
              ),
              headerPadding: const EdgeInsets.symmetric(vertical: 8.0), // 패딩 설정
              leftChevronIcon: Icon(
                Icons.arrow_left_rounded, // 원 안의 왼쪽 화살표
                color: Colors.green[300],
                size: 40,
              ),
              rightChevronIcon: Icon(
                Icons.arrow_right_rounded, // 원 안의 오른쪽 화살표
                color: Colors.green[300],
                size: 40,
              ),
              leftChevronMargin: const EdgeInsets.only(left: 16.0), // 왼쪽 버튼 여백
              rightChevronMargin: const EdgeInsets.only(right: 16.0), // 오른쪽 버튼 여백
              leftChevronPadding: const EdgeInsets.all(8.0), // 왼쪽 버튼 내부 패딩
              rightChevronPadding: const EdgeInsets.all(8.0), // 오른쪽 버튼 내부 패딩
            ),
            calendarStyle: CalendarStyle(
              isTodayHighlighted: true,
              outsideDaysVisible: true,
              todayDecoration: BoxDecoration(
                color: Colors.amber[200],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(color: Colors.orangeAccent, width: 2.0),
              ),
              todayTextStyle: const TextStyle(color: Colors.black,fontFamily: "NamuL",),
              selectedDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
              weekendDecoration: BoxDecoration(
                color: Colors.transparent,
                // Transparent background
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.deepOrangeAccent, // Border color
                  width: 2.0, // Border width
                ),
              ),
              holidayDecoration: BoxDecoration(
                color: Colors.transparent,
                // Transparent background
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                  color: Colors.deepOrangeAccent, // Border color
                  width: 2.0, // Border width
                ),
              ),
              defaultDecoration: BoxDecoration(
                color: Colors.amber[200],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) =>
                  events.isNotEmpty ? _buildEventsMarker(date, events) : null,
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 63),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _isMealLoaded && _isTimetableLoaded
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                final events =
                                    _getEventsForRange(_rangeStart, _rangeEnd);
                                return events.isEmpty
                                    ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center, // 세로축 중앙 정렬
                                    children: [
                                      Image(
                                        image: AssetImage('assets/dog.png'), // 로컬 이미지 경로
                                        fit: BoxFit.contain,   // 이미지가 화면에 맞게 조정
                                        width: 150,
                                        height: 150,
                                      ),
                                      SizedBox(height: 16),    // 이미지와 텍스트 사이 간격
                                      Text(
                                        '오늘 일정 없어요',
                                        style: TextStyle(fontSize: 16, color: Colors.grey,fontFamily: "NamuL",),
                                      ),
                                    ],
                                  ),
                                )
                                    : ListView.builder(
                                        itemCount: events.length,
                                        itemBuilder: (context, index) {
                                          final event = events[index];
                                          final randomColor = colors[
                                              random.nextInt(colors.length)];
                                          return Container(
                                            height: 60.0,
                                            color: randomColor,
                                            child: ListTile(
                                              leading: const Icon(Icons.alarm,
                                                  color: Colors.white),
                                              title: Container(
                                                  padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                             child: Text(
                                                event['title'],
                                                style: const TextStyle(
                                                    fontFamily: "NamuL",
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                              ),

                                              onTap: () => Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context,
                                                          animation,
                                                          secondaryAnimation) =>
                                                      CalendarDetails(
                                                    event: event,
                                                    deleteEvent: _deleteEvent,
                                                    updateEvent: _updateEvent,
                                                  ),
                                                  transitionsBuilder: (context,
                                                      animation,
                                                      secondaryAnimation,
                                                      child) {
                                                    return SlideTransition(
                                                      position: animation.drive(Tween(
                                                              begin:
                                                                  const Offset(
                                                                      1.0, 0.0),
                                                              end: Offset.zero)
                                                          .chain(CurveTween(
                                                              curve: Curves
                                                                  .easeInOut))),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                              },
                            ),
                          ),
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 300, // 컨테이너 높이 제한
                              ),
                              margin: const EdgeInsets.fromLTRB(20, 5, 20, 40),
                              padding: const EdgeInsets.all(0.0),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.withAlpha(128),
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: timetable
                                              .isNotEmpty // 리스트가 비어 있지 않은지 확인
                                          ? Text(
                                              '${timetable[0]} 시간표',
                                              style: TextStyle(
                                                fontFamily: "NamuL",
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Container(
                                        padding: const EdgeInsets.fromLTRB(0,60,0,0), // 패딩 추가 (상하좌우 16픽셀)
                                        alignment: Alignment.center, // 컨테이너 내부에서 중앙 정렬
                                        child: Text(
                                          '즐거운 주말', // 예외 상황에 보여줄 텍스트
                                          style: TextStyle(
                                            fontFamily: "NamuL",
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[100],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (_selectedDay!.weekday >= 6)
                                      const Center(
                                        child: Text(
                                          '',
                                          style: TextStyle(
                                            fontFamily: "NamuL",
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    else
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: List.generate(
                                          6,
                                          (index) => Expanded(
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withOpacity(0.5),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                border: Border.all(
                                                    color:
                                                        Colors.orange,
                                                    width: 0.1),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                    blurRadius: 5,
                                                    offset: const Offset(2, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${index + 1}교시',
                                                    style: TextStyle(

                                                      fontFamily: "NamuL",
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green[100],
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    timetable.length > index + 1
                                                        ? timetable[index + 1]
                                                        : '',
                                                    style: const TextStyle(
                                                      fontFamily: "NamuL",
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white70,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 300, // 컨테이너 높이 제한
                              ),
                              margin: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent.withAlpha(128),
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: mealDate != null && mealMenu != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 16),
                                        Container(
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.orangeAccent
                                                  .withAlpha(128),
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              border: Border.all(
                                                color: Colors.orangeAccent,
                                                width: 1.0,
                                              ),

                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center, // 중앙 정렬
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    // 왼쪽 이미지
                                                    Image.asset(
                                                      'assets/seekpan.png', // 왼쪽 이미지 경로
                                                      width: 40, // 이미지 너비
                                                      height: 30, // 이미지 높이
                                                      fit: BoxFit.cover,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // 이미지와 텍스트 사이 간격

                                                    // 날짜 텍스트
                                                    Text(
                                                      formatMealDate(mealDate!),
                                                      // 날짜 텍스트
                                                      style: const TextStyle(
                                                        fontFamily: "NamuL",
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors
                                                            .deepOrangeAccent,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // 텍스트와 이미지 사이 간격

                                                    // 오른쪽 이미지
                                                    Image.asset(
                                                      'assets/seekpan.png', // 오른쪽 이미지 경로
                                                      width: 40, // 이미지 너비
                                                      height: 30, // 이미지 높이
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ],
                                                ),

                                                const SizedBox(
                                                    height:
                                                        8), // 텍스트와 아래 컨텐츠 간격

                                                // 식단 텍스트
                                                Text(
                                                  cleanMealData(mealMenu!),
                                                  style: const TextStyle(
                                                    fontFamily: "NamuL",
                                                    fontSize: 16,
                                                    color: Colors.white70,
                                                    fontWeight: FontWeight.bold,// 텍스트 색상
                                                    shadows: [
                                                      Shadow(
                                                        offset: Offset(1, 1), // 그림자의 위치 (X, Y)
                                                        blurRadius: 3.0, // 그림자 흐림 정도
                                                        color: Color(0x55000000), // 그림자 색상 (반투명 검정)
                                                      ),
                                                    ],
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  softWrap: true,
                                                ),
                                              ],
                                            )),
                                      ],
                                    )
                                  : Center(
                                      child: AnimatedTextKit(
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                          '오늘은 급식이 없어요',
                                          textStyle: TextStyle(
                                            fontFamily: "NamuL",
                                            fontSize: 32.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green[100],
                                          ),
                                          speed:
                                              const Duration(milliseconds: 200),
                                        ),
                                      ],
                                      totalRepeatCount: 1,
                                      pause: const Duration(milliseconds: 300),
                                      displayFullTextOnTap: true,
                                      stopPauseOnTap: true,
                                    )),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text(""), // 로딩 상태
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCalendar();
    fetchSchoolCodes();
    initializeDateFormatting();

    final DateTime now = DateTime.now();
    _selectedDay = now;
    _focusedDay = now;
    final DateTime date = DateTime.now();
    _rangeStart = DateTime(date.year, date.month, date.day)
        .add(const Duration(hours: 9))
        .toUtc();
    _rangeEnd = DateTime(date.year, date.month, date.day)
        .add(const Duration(hours: 9))
        .toUtc();

  }

  // 상태를 갱신하는 함수

  @override
  Widget build(BuildContext context) {
    // 정상적으로 데이터가 로드되었을 때
    return Scaffold(
      body: body(), // 기존 body() 함수 호출
      bottomNavigationBar: Container(
        height: 80.0,
        // 바텀바 높이
        decoration: BoxDecoration(
          color: const Color(0xFFFFEFB0), // 바텀바 배경색
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.4), // 올바르게 호출
              width: 1.0, // 경계선 두께
            ),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent, // 배경색 투명 (Container에서 설정)
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
                final DateTime date = DateTime.now();
                _rangeStart = DateTime(date.year, date.month, date.day)
                    .add(const Duration(hours: 9))
                    .toUtc();
                _rangeEnd = DateTime(date.year, date.month, date.day)
                    .add(const Duration(hours: 9))
                    .toUtc();
                fetchSchoolMealInfo(apiKey, _selectedDay!);
                int? weekday = _selectedDay?.weekday;
                fetchWeekdayInfo(weekday!);
              });
            },
            child: Center(
              child: Text(
                '오늘',
                style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: "NamuL",
                  // 글씨 크기
                  fontWeight: FontWeight.bold,
                  // 글씨 두께
                  color: Color(0xFF9BB8D5),
                  // 글씨 색상
                  letterSpacing: 2.0,
                  // 글자 간격
                  shadows: [
                    Shadow(
                      offset: Offset(1.0, 1.0), // 텍스트 그림자 위치
                      blurRadius: 3.0, // 텍스트 그림자 흐림
                      color: Colors.black.withOpacity(0.5), // 텍스트 그림자 색상
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void fetchWeekdayInfo(int weekday) {
    switch (weekday) {
      case 1: // 월요일
        timetable = ['월요일', '국어', '수학', '수학', '영어', '과학', '체육'];
        break;
      case 2: // 화요일
        timetable = ['화요일', '음악', '미술', '국어', '체육', '체육', '체육'];
        break;
      case 3: // 수요일
        timetable = ['수요일', '영어', '역사', '과학', '음악', '미술', '마술'];
        break;
      case 4: // 목요일
        timetable = ['목요일', '국어', '체육', '영어', '수학', '과학', '과학'];
        break;
      case 5: // 금요일
        timetable = ['금요일', '역사', '음악', '체육', '미술', '국어', '수학'];
        break;
      case 6: // 토요일
      case 7: // 일요일
        timetable = [];
        break;
      default: // 잘못된 요일
        timetable = [];
    }
    _isTimetableLoaded = true; // 시간표 정보 로드 완료
  }
}
