import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:lastdance_f/home_screen.dart';
import 'package:lastdance_f/scanner.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  // await initializeDateFormatting('ko_KR'); // 로케일 초기화
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('로고는 여기 위에'),
                ElevatedButton(
                  child: const Text('QR 코드로 로그인하기'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      // builder: (context) => QRScanner(),
                      builder: (context) => HomeScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
