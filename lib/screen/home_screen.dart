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
import '../screen/calendar.dart';
import '../screen/myPage.dart';
import '../screen/notice.dart';
import '../screen/seat.dart';
import '../screen/vote.dart';
import '../student.dart';

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

  @override
  void initState() {
    super.initState();
    classDetailsFuture = _fetchClassDetails(widget.student.classId);
    _fetchStudentId(widget.student.classId).then((_) {
      _initializeNotifications();
    });
  }

  Future<void> _fetchStudentId(int classId) async {
    final dio = Dio();
    final serverURL = _getServerURL();

    try {
      final response = await dio.get(
          '$serverURL/api/students/get/class/$classId/no/${widget.student.studentInfo.studentNo}');
      if (response.statusCode == 200) {
        final data = response.data;
        _studentId = data is int ? data : int.tryParse(data.toString()) ?? 0;
      }
    } catch (e) {
      debugPrint("Error fetching student ID: $e");
    }
  }

  Future<Map<String, dynamic>> _fetchClassDetails(int classId) async {
    try {
      final dio = Dio();
      final serverURL = _getServerURL();
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

  void _initializeNotifications() {
    _requestNotificationPermission();
    initNotification();
    _firebaseMessaging.getToken().then((token) {
      if (token != null) _sendTokenToServer(token);
    });
    FirebaseMessaging.onMessage.listen((message) => showNotification(
        message.notification?.title, message.notification?.body));
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

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    // Handle background notifications
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
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            classDetails['classNickname'] ?? 'Home',
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
        body: Text('$_studentId'));
  }

  Drawer _buildDrawer(Map<String, dynamic> classDetails) {
    return Drawer(
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
          _buildDrawerItem(title: '캘린더', onTap: () => _navigateTo(Calendar())),
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
