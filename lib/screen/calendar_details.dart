
import 'package:flutter/material.dart';

import '../model/calendar_model.dart';


class CalendarDetails extends StatefulWidget {
  final dynamic event;
  final Function(int id) deleteEvent;
  final Function(dynamic event) updateEvent;

  const CalendarDetails(
      {super.key,
      required this.event,
      required this.deleteEvent,
      required this.updateEvent});

  @override
  State<CalendarDetails> createState() => _CalendarDetailsState();
}

class _CalendarDetailsState extends State<CalendarDetails> {
  final CalendarModel _calendarModel = CalendarModel();
  dynamic event2;
  bool canDismiss = false; // 조건 변수
  @override
  void initState() {
    super.initState();
    event2 = widget.event ?? {}; // 여기서 widget에 안전하게 접근 가능
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('이벤트 세부사항'),
          centerTitle: true,
          leadingWidth: 90,
          leading: SizedBox(
            width: 130, // leading의 크기 제한
            child: Row(
              mainAxisSize: MainAxisSize.min, // Row 크기를 최소화하여 공간 초과 방지
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left), // 뒤로가기 화살표
                  onPressed: () {
                    Navigator.pop(context); // 뒤로 가기 동작
                  },
                ),
                Flexible(
                  // 텍스트 길이 제어
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0.1), // 화살표와 텍스트 간격 조정
                    child: Text(
                      event2 != null && event2['start'] != null // 유효성 검사
                          ? '${event2['start'].toString().substring(5, 7)} 월' // 날짜 출력
                          : 'No Date',
                      style: const TextStyle(
                        fontSize: 16, // 텍스트 크기 줄이기

                        color: Color(0xff3CB371),
                      ),
                      overflow: TextOverflow.ellipsis, // 텍스트 초과 시 "..."로 표시
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이벤트 제목
            Text(
              event2['title'],
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xff309729),
              ),
            ),
            const SizedBox(height: 16),

            // 시작일
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '시작일 : ${event2['start'].toString().substring(0, 10)}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 종료일
            Row(
              children: [
                const Icon(Icons.event_available, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '종료일 : ${event2['end'].toString().substring(0, 10)}',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 구분선
            const Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),

            // 메모 영역
            Container(
              height: MediaQuery.of(context).size.height * 0.4, // 화면 높이의 30%로 설정
              padding: const EdgeInsets.all(16),
              width: double.infinity, // 전체 너비 사용



              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 메모 제목
                  Row(
                    children: [
                      const Icon(Icons.note, size: 20, color: Color(0xff309729)),
                      const SizedBox(width: 8),
                      const Text(
                        '메모',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 메모 내용
                  Text(
                    event2['description'] ?? '메모가 없습니다.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),


          ],
        ),
      ),




    );
  }

  void _showDeleteModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16), // Rounded top corners
        ),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grouped container for the confirmation text and delete button
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white70, // Button background
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Confirmation text
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        '이 이벤트를 삭제하겠습니까?', // Confirmation text
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black, // Text color
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ), // Divider
                    const Divider(
                      height: 1, thickness: 1,
                      color: Colors.grey, // Divider color
                    ), // Delete button
                    InkWell(
                      onTap: () {
                        widget.deleteEvent(widget.event['calendarId']);
                        Navigator.pop(context); // Close modal
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Text(
                          '이벤트 삭제', // Delete text
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red, // Red text color
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ), // Cancel button (independent)
              InkWell(
                onTap: () {
                  Navigator.pop(context); // Close modal
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white, // Button background
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    '취소', // Cancel text
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black, // Text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EditEventScreen extends StatelessWidget {
  final dynamic event;

  const EditEventScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
      ),
      body: Center(
        child: Text('Edit screen for: ${event['title']}'),
      ),
    );
  }
}
