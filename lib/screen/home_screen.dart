import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../dialog/end_drawer.dart';
import '../notification/init_noti.dart';
import '../notification/show_noti.dart';
import '../screen/my_page.dart';
import '../screen/notice.dart';
import '../screen/seat.dart';
import '../screen/vote.dart';
import '../student.dart';
import 'main_body.dart';

class HomeScreen extends StatefulWidget {
  final Student student;

  const HomeScreen({super.key, required this.student});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

String _getServerURL() {
  return kIsWeb
      ? dotenv.env['FETCH_SERVER_URL2']!
      : dotenv.env['FETCH_SERVER_URL']!;
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> classDetailsFuture;
  int _studentId = 0;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _studentIdFetched = false;
  bool _classDetailsFetched = false;

  @override
  void initState() {
    super.initState();
    classDetailsFuture = _fetchClassDetails();
    _fetchStudentId(widget.student.classId).then((_) {
      _initializeNotifications();
    });
  }

  Future<void> _fetchStudentId(int classId) async {
    if(_studentIdFetched) return;

    final dio = Dio();
    final serverURL = _getServerURL();

    try {
      final response = await dio.get(
          '$serverURL/api/students/get/class/$classId/no/${widget.student.studentInfo.studentNo}');
      if (response.statusCode == 200) {
        final data = response.data;
        _studentId = data is int ? data : int.tryParse(data.toString()) ?? 0;
        _studentIdFetched = true;
      }
    } catch (e) {
      debugPrint("Error fetching student ID: $e");
    }
  }

  Future<Map<String, dynamic>> _fetchClassDetails() async {
    if (_classDetailsFetched) {
        return classDetailsFuture;
    }

    final dio = Dio();
    final serverURL = _getServerURL();

    try {
      final response = await dio.get('$serverURL/class/${widget.student.classId}');
      if (response.statusCode == 200) {
        _classDetailsFetched = true;
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to fetch class details.");
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {}

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> sendTokenToServer(String token, int studentId) async {
    final url = Uri.parse("http://112.221.66.174:3013/fcm/register-token");

    final body = jsonEncode({
      "token": token,
      "studentId": studentId,
    });

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
  }

  void _initializeNotifications() {
    _requestNotificationPermission();
    initNotification();
    _firebaseMessaging.getToken().then((token) {
      if (token != null) _sendTokenToServer(token);
    });
    FirebaseMessaging.onMessage.listen((message) => showNotification(
        message.notification?.title, message.notification?.body));
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    final url = Uri.parse("http://112.221.66.174:6892/fcm/register-token");
    final body = jsonEncode({"token": token, "studentId": _studentId});
    try {
      await http.post(url,
          headers: {"Content-Type": "application/json"}, body: body);
    } catch (e) {
      debugPrint("Error sending token to server: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: classDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return _buildScaffold(snapshot.data!);
        } else if (snapshot.hasError) {
          return Center(child: Text("오류: ${snapshot.error}"));
        } else {
          return const Center(child: Text("오류"));
        }
      },
    );
  }

  Scaffold _buildScaffold(Map<String, dynamic> classDetails) {

    return Scaffold(
        backgroundColor: Color(0xFFFFEFB0),
        key: _scaffoldKey,
        appBar: AppBar(

          title: Text(
            classDetails['classNickname'] ?? '홈',
            style: const TextStyle(fontSize: 20),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ],
        ),
        drawer: _buildDrawer(classDetails),
        endDrawer: EndDrawerWidget(
            classId: widget.student.classId, studentId: _studentId),
        body: HomeContent(schoolName: widget.student.studentInfo.studentName),
    );
  }

  Drawer _buildDrawer(Map<String, dynamic> classDetails) {
    return Drawer(
      backgroundColor: Color(0xFFFFEFB0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Text(
              '${classDetails['schoolName']} ${classDetails['grade']}학년 ${classDetails['classNo']}반\n'
              '${widget.student.studentInfo.studentName}',
              style: const TextStyle(fontSize: 24),
            ),
          ),
          _buildDrawerItem(title: '홈', onTap: () => Navigator.pop(context)),
          _buildDrawerItem(
              title: '공지사항',
              onTap: () =>
                  _navigateTo(Notice(classId: widget.student.classId))),
          _buildDrawerItem(
              title: '마이 페이지',
              onTap: () => _navigateTo(MyPage(studentId: _studentId))),

          _buildDrawerItem(
              title: '우리반 좌석 보기',
              onTap: () => _navigateTo(Seat(classId: widget.student.classId))),
          _buildDrawerItem(
              title: '학급 투표',
              onTap: () => _navigateTo(Vote(
                  classId: widget.student.classId, studentId: _studentId))),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(
      {required String title, required VoidCallback onTap}) {
    return ListTile(title: Text(title), onTap: onTap);
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}