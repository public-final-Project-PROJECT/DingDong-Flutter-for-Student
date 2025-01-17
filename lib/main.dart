import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lastdance_f/screen/home_screen.dart';
import 'package:lastdance_f/screen/scanner.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _skipQRLogin = false;

  @override
  void initState() {
    super.initState();
    _checkStoredQRData();
  }

  Future<void> _checkStoredQRData() async {
    final qrData = await _storage.read(key: 'qrData');
    final expirationDateStr = await _storage.read(key: 'expirationDate');

    if (qrData != null && expirationDateStr != null) {
      final expirationDate = DateTime.parse(expirationDateStr);

      if (DateTime.now().isBefore(expirationDate)) {
        setState(() {
          _skipQRLogin = true;
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return MaterialApp(
      home: _skipQRLogin ? const HomeScreen() : const QRLoginScreen(),
    );
  }
}

class QRLoginScreen extends StatelessWidget {
  const QRLoginScreen({super.key});

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
                  builder: (context) => QRScanner()
                  // builder: (context) => HomeScreen()
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
