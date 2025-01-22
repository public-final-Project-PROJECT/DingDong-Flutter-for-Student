import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:lastdance_f/screen/home_screen.dart';
import 'package:lastdance_f/screen/scanner.dart';
import 'package:lastdance_f/student.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}




  class _LoginScreenState extends State<LoginScreen>
  with SingleTickerProviderStateMixin {

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
  super.initState();

  // AnimationController 설정
  _shakeController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 400),
  );

  // -10 ~ 10 구간으로 좌우 흔들림 설정 (Curves.easeInOut)
  _shakeAnimation = Tween<double>(begin: -10, end: 10)
      .chain(CurveTween(curve: Curves.easeInOut))
      .animate(_shakeController);

  // 애니메이션을 반복(왕복)하도록 설정
  _shakeController.repeat(reverse: true);
  }

  @override
  void dispose() {
  // 꼭 dispose에서 해제해주어야 메모리 누수가 발생하지 않습니다.
  _shakeController.dispose();
  super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                // 흔들림(Shake)을 표현하기 위해 좌우 이동(translate)
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              // 흔들리는 대상만 child로 두면, builder에서는 흔들림 처리만 해주면 됨
              child: Image.asset(
                'assets/logo.png',
                width: 350,
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
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
            ),
            TextButton(
              child: const Text('로그인 건너뛰기',
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
