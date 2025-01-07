import 'package:flutter/material.dart';
import 'package:lastdance_f/student.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required Student student});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("인증 완료 화면 예시")),
      body: Center(child: Text("인증 완료 화면 예시")),
    );
  }
}
