import 'package:flutter/material.dart';
import 'package:lastdance_f/screen/home_screen.dart';
import 'package:lastdance_f/screen/scanner.dart';
import 'package:lastdance_f/student.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('로고는 여기 위에'),
            ElevatedButton(
              child: const Text('QR 코드로 로그인하기'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QRScanner(),
                ),
              ),
            ),
            TextButton(
              child: const Text('로그인 건너뛰기'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                        student: Student(
                            studentInfo: StudentInfo(
                                schoolName: "서이초등학교",
                                studentNo: 1,
                                studentName: "테스트"),
                            teacherId: 3,
                            classId: 4,
                            year: 2025)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
