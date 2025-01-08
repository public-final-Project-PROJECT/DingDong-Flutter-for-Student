import 'package:flutter/material.dart';
import 'package:lastdance_f/student.dart';

class AuthSucceeded extends StatefulWidget {
  const AuthSucceeded({super.key, required Student student});

  @override
  State<AuthSucceeded> createState() => _AuthSucceededState();
}

class _AuthSucceededState extends State<AuthSucceeded> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("인증 완료 화면 예시")),
      body: Center(child: Text("인증 완료 화면 예시")),
    );
  }
}
