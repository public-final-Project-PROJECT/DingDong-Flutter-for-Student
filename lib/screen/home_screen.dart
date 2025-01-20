import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lastdance_f/dialog/end_drawer.dart';
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

class HomeScreen extends StatefulWidget {
  final Student student;

  const HomeScreen({super.key, required this.student});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _studentId = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<Map<String, dynamic>> classDetailsFuture;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _fetchStudentId(widget.student.classId);
    classDetailsFuture = _fetchClassDetails(widget.student.classId);
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _requestNotificationPermission();
    initNotification();

    _firebaseMessaging.getToken().then((token) {
      if (token != null) {
        _sendTokenToServer(token, _studentId);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message.notification?.title, message.notification?.body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle background notification tap
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    // Handle background notifications
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _sendTokenToServer(String token, int studentId) async {
    final url =
        Uri.parse("http://112.221.66.174:6892/fcm/register-token");
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

  Future<void> _fetchStudentId(int classId) async {
    try {
      final dio = Dio();
      final serverURL = _getServerURL();
      final response = await dio.get(
          '$serverURL/api/students/get/$classId/${widget.student.studentInfo.studentNo}');

      if (response.statusCode == 200) {
        final data = response.data;
        _studentId = data is int ? data : int.tryParse(data.toString()) ?? 0;
      } else {
        throw Exception("Failed to fetch class details.");
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  String _getServerURL() {
    return kIsWeb
        ? dotenv.env['FETCH_SERVER_URL2']!
        : dotenv.env['FETCH_SERVER_URL']!;
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
          return _buildScaffold(snapshot.data!);
        } else if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error);
        } else {
          return const Center(child: Text("오류"));
        }
      },
    );
  }

  Scaffold _buildScaffold(Map<String, dynamic> classDetails) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(classDetails['classNickname']),
      drawer: _buildDrawer(classDetails),
      endDrawer: const EndDrawerWidget(),
      body: _pages[_selectedIndex],
    );
  }

  AppBar _buildAppBar(String classNickname) {
    return AppBar(
      title: Text(
        classNickname,
        style: const TextStyle(fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      ],
    );
  }

  Drawer _buildDrawer(Map<String, dynamic> classDetails) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(classDetails),
          _buildDrawerItem('홈', Icons.home, 0),
          _buildDrawerItem('공지사항', Icons.announcement, 1),
          _buildDrawerItem('마이 페이지', Icons.person, 2),
          _buildDrawerItem('캘린더', Icons.calendar_today, 3),
          _buildDrawerItem('우리반 좌석보기', Icons.table_restaurant_outlined, 4),
          _buildDrawerItem('학급 투표', Icons.how_to_vote_outlined, 5),
        ],
      ),
    );
  }

  DrawerHeader _buildDrawerHeader(Map<String, dynamic> classDetails) {
    return DrawerHeader(
      child: Text(
        '${classDetails['schoolName']} '
        '${classDetails['grade']}학년 '
        '${classDetails['classNo']}반\n'
        '${widget.student.studentInfo.studentName}',
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  ListTile _buildDrawerItem(String title, IconData icon, int index) {
    return ListTile(
      title: Row(
        children: [
          Icon(icon, color: Colors.deepOrange, size: 30),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
      onTap: () {
        _onTapped(index);
        Navigator.pop(context);
      },
    );
  }

  Scaffold _buildErrorScreen(Object? error) {
    return Scaffold(
      body: Center(
        child: Text(
          "오류: $error",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
