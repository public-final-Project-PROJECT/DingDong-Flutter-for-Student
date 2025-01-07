import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("인증 완료 화면 예시")),
      body: Center(child: Text("인증 완료 화면 예시")),
    );
  }
}
