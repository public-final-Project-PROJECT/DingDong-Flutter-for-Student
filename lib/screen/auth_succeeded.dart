// ignore_for_file: use_build_context_synchronously

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lastdance_f/main.dart';
import 'package:lastdance_f/screen/home_screen.dart';
import 'package:lastdance_f/student.dart';

class AuthSucceeded extends StatefulWidget {
  const AuthSucceeded({super.key, required this.student});

  final Student student;

  @override
  State<AuthSucceeded> createState() => _AuthSucceededState();
}

class _AuthSucceededState extends State<AuthSucceeded> {
  late Future<Map<String, dynamic>> classDetailsFuture;

  @override
  void initState() {
    super.initState();
    classDetailsFuture = _fetchClassDetails(widget.student.classId);
  }

  String getServerURL() {
    return kIsWeb
        ? dotenv.env['FETCH_SERVER_URL2']!
        : dotenv.env['FETCH_SERVER_URL']!;
  }

  Future<Map<String, dynamic>> _fetchClassDetails(int classId) async {
    try {
      final dio = Dio();
      String serverURL = getServerURL();
      final response = await dio.get('$serverURL/class/$classId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to fetch class details.");
      }
    } catch (e) {
      throw Exception("Error: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (popDisposition, result) async {
        return;
      },
      child: Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
          future: classDetailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("우리반을 찾을 수 없어요.",
                        style: TextStyle(fontSize: 18, fontFamily: "NamuL")),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => MyApp()),
                          (route) => false),
                      child: const Text("뒤로",
                          style: TextStyle(
                            fontFamily: "NamuL",
                          )),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              final classDetails = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${classDetails['schoolName']} "
                      "${classDetails['grade']}학년 "
                      "${classDetails['classNo']}반",
                      style: const TextStyle(fontSize: 20, fontFamily: "NamuL"),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "우리반이 맞나요?",
                      style: TextStyle(fontFamily: "NamuL"),
                    ),
                    const SizedBox(height: 10),
                    const Text("\"네\"를 누르면 어플을 삭제하기 전까지 우리반을 변경할 수 없어요.",
                        style: TextStyle(
                          fontFamily: "NamuL",
                        )),
                    const SizedBox(height: 20),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            child: const Text("네",
                                style: TextStyle(
                                  fontFamily: "NamuL",
                                )),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomeScreen(student: widget.student)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            child: const Text("아니오",
                                style: TextStyle(
                                  fontFamily: "NamuL",
                                )),
                            onPressed: () async {
                              final FlutterSecureStorage storage =
                                  const FlutterSecureStorage();
                              await storage.delete(key: 'qrData');
                              await storage.delete(key: 'expirationDate');

                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => MyApp()),
                                  (route) => false);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                  child: Text("오류",
                      style: TextStyle(
                        fontFamily: "NamuL",
                      )));
            }
          },
        ),
      ),
    );
  }
}
