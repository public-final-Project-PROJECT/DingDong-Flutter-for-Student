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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/QRcode.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'QR 코드로 로그인하기',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QRScanner(),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: const Size(220, 50),
                elevation: 1.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
            TextButton(
              child: const Text('로그인건너뛰기',
                style: TextStyle(
                  fontSize: 14,
                  height: 5,
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
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
