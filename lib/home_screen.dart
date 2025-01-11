import 'package:flutter/material.dart';
import 'package:lastdance_f/screen/calendar.dart';
import 'package:lastdance_f/screen/home.dart';
import 'package:lastdance_f/screen/myPage.dart';
import 'package:lastdance_f/screen/notice.dart';
import 'package:lastdance_f/screen/vote.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Home(),
    Notice(),
    Mypage(),
    Calendar(),
    Vote(),
  ];

  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 8),
            Text(
              "~~~반 ",
              style: TextStyle(fontSize: 20),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                print("알림 아이콘 클릭됨");
              },
            ),
          ],
        ),
        centerTitle: false,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(
                '몇학년 몇반 누구누구',
                style: TextStyle(fontSize: 24),
              ),
            ),
            ListTile(
              title: Text('공지사항'),
              onTap: () {
                _onTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('마이 페이지'),
              onTap: () {
                _onTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('캘린더'),
              onTap: () {
                _onTapped(3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('투표'),
              onTap: () {
                _onTapped(4);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}