import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lastdance_f/screen/home_screen.dart';
import 'package:lastdance_f/screen/scanner.dart';
import 'package:lastdance_f/student.dart';

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
  Student? _student;

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
        try {
          final parsedData = jsonDecode(qrData);
          setState(() {
            _student = Student.fromJson(parsedData);
          });
        } catch (e) {
          throw Exception("Failed to parse QR data: $e");
        }
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
        home: _student != null
            ? HomeScreen(student: _student!)
            : QRScanner()
    );
  }
}
