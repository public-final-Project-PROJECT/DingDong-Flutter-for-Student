import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lastdance_f/screen/home_screen.dart';
import 'package:lastdance_f/screen/login_screen.dart';
import 'package:lastdance_f/student.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
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

        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: Color(0xFFFFEFB0),
          appBarTheme: AppBarTheme(
            color: Color(0xFFFFEFB0),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.black),
          ),
          bottomAppBarTheme: BottomAppBarTheme(
            color: Color(0xFFFFEFB0),
            elevation: 4.0,
          ),
        ),
        home: _student != null
            ? HomeScreen(student: _student!)
            : LoginScreen()
    );
  }
}
