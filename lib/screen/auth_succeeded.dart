import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lastdance_f/screen/home_screen.dart';
import 'package:lastdance_f/main.dart';
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

  Future<Map<String, dynamic>> _fetchClassDetails(int classId) async {
    try {
      final dio = Dio();
      final serverURL = dotenv.get("FETCH_SERVER_URL");
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
    return Scaffold(
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
                  const Text("클래스 정보를 불러올 수 없습니다.",
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("뒤로"),
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
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text("우리반이 맞나요?"),
                  const SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: const Text("네"),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          child: const Text("아니오"),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MyApp(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("데이터가 없습니다."));
          }
        },
      ),
    );
  }
}
