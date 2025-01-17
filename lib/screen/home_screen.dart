import 'package:flutter/material.dart';
import 'package:lastdance_f/screen/seat.dart';
import 'package:lastdance_f/dialog/endDrawer.dart';
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
            Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {

                    Scaffold.of(context).openEndDrawer();
                  },
                );
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
              title :
              Row(
                children: [
                  Icon(Icons.table_restaurant_outlined, color: Colors.deepOrange, size: 30,),
                  SizedBox(width: 10,),
                  Text('우리반 좌석보기'),
                ],
              ),
              onTap: (){
                _onTapped(4);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title:
              Row(
                children: [
                  Icon(Icons.how_to_vote_outlined,  color: Colors.deepOrange, size: 30,),
                  SizedBox(width: 10,),
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
  }
}