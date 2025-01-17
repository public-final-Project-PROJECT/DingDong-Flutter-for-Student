import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lastdance_f/dialog/endDrawer.dart';
import 'package:lastdance_f/screen/calendar.dart';
import 'package:lastdance_f/screen/home.dart';
import 'package:lastdance_f/screen/myPage.dart';
import 'package:lastdance_f/screen/notice.dart';
import 'package:lastdance_f/screen/seat.dart';
import 'package:lastdance_f/screen/vote.dart';
import 'package:lastdance_f/student.dart';

class HomeScreen extends StatefulWidget {
  final Student student;

  const HomeScreen({super.key, required this.student});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<Map<String, dynamic>> classDetailsFuture;

  String getServerURL() {
    return kIsWeb
        ? dotenv.env['FETCH_SERVER_URL2']!
        : dotenv.env['FETCH_SERVER_URL']!;
  }

  @override
  void initState() {
    super.initState();
    classDetailsFuture = _fetchClassDetails(widget.student.classId);
  }

  Future<Map<String, dynamic>> _fetchClassDetails(int classId) async {
    try {
      final dio = Dio();
      String serverURL = getServerURL();
      final response = await dio.get('$serverURL/class/$classId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to fetch class details.");
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  final List<Widget> _pages = [
    Home(),
    Notice(),
    Mypage(),
    Calendar(),
    Seat(),
    Vote(),
  ];

  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: classDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          final classDetails = snapshot.data!;
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(
                "${classDetails['classNickname']}",
                style: const TextStyle(fontSize: 20),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    child: Text(
                      '${classDetails['schoolName']} '
                      '${classDetails['grade']}학년 '
                      '${classDetails['classNo']}반 '
                      '${widget.student.studentInfo.studentName}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  ListTile(
                    title: const Text('홈'),
                    onTap: () {
                      _onTapped(0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('공지사항'),
                    onTap: () {
                      _onTapped(1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('마이 페이지'),
                    onTap: () {
                      _onTapped(2);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('캘린더'),
                    onTap: () {
                      _onTapped(3);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: const [
                        Icon(
                          Icons.table_restaurant_outlined,
                          color: Colors.deepOrange,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text('우리반 좌석보기'),
                      ],
                    ),
                    onTap: () {
                      _onTapped(4);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Row(
                      children: const [
                        Icon(
                          Icons.how_to_vote_outlined,
                          color: Colors.deepOrange,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text('학급 투표'),
                      ],
                    ),
                    onTap: () {
                      _onTapped(5);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            endDrawer: EndDrawerWidget(),
            body: _pages[_selectedIndex],
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                "오류: ${snapshot.error}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          );
        } else {
          return const Center(
            child: Text("오류"),
          );
        }
      },
    );
  }
}
