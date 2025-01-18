import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lastdance_f/dialog/endDrawer.dart';
import 'package:lastdance_f/notification/init_noti.dart';
import 'package:lastdance_f/notification/show_noti.dart';
import 'package:lastdance_f/screen/calendar.dart';
import 'package:lastdance_f/screen/home.dart';
import 'package:lastdance_f/screen/myPage.dart';
import 'package:lastdance_f/screen/notice.dart';
import 'package:lastdance_f/screen/seat.dart';
import 'package:lastdance_f/screen/vote.dart';
import 'package:lastdance_f/student.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

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

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    classDetailsFuture = _fetchClassDetails(widget.student.classId);

    requestNotificationPermission();
    initNotification();//init 추가

    //앱 실행시 firebase 에서 토큰 가져오는 메소드
    _firebaseMessaging.getToken().then((token){
      print("FCM token : $token");

      //서버로 토큰 전송

      if(token != null){
        sendTokenToServer(token ,1);
      }

    });
    //포그라운드 상태에서 알림을 처리하기 위한 핸들러
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      print("Foreground message : ${message.notification?.title}");
      showNotification(message.notification?.title, message.notification?.body);
    });

    //알람을 클릭해서 앱이 열릴 때 핸들러
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      print("알람을 클릭해서 앱이 열리는 상태 : ${message.notification?.title}");
    });


    //백그라운드 및 종료 상태에서 알람을 처리하기 위한 핸들러
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  }
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async{
    print("BackgroundMessage Message : ${message.notification?.title}");
  }

  //권한 설정 메소드
  Future<void> requestNotificationPermission() async{
    if(await Permission.notification.isDenied){
      await Permission.notification.request();
    }
  }

  Future<void> sendTokenToServer(String token, int studentId) async {
    final url = Uri.parse("http://112.221.66.174:6892/fcm/register-token");

    final body = jsonEncode({
      "token": token,
      "studentId": studentId,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      print("토큰 전송 성공");
    } else {
      print("전송 실패: ${response.statusCode}");
      print("에러 메시지: ${response.body}");
    }
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
