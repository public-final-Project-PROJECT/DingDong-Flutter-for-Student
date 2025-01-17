import 'package:dio/dio.dart';

class StudentModel {
  Future<Map<String, dynamic>> searchDetailStudent(int student) async {
    final dio = Dio();
    try {
      final response = await dio
          .get("http://112.221.66.174:6892/api/students/viewClass/$student");
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
  }
}
