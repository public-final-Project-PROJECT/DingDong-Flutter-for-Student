import 'package:dio/dio.dart';

class SeatModel {
  Future<List<dynamic>> selectSeatTable(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/seat/findAllSeat",
          data: {'classId': 2});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      throw Exception("로드 실패 !");
    } catch (e) {
      throw Exception("Error 좌석 조회 중 : $e");
    }
  }

  Future<List<dynamic>?> studentNameAPI() async {
    final dio = Dio();

    try {
      final response = await dio.post(
        "http://112.221.66.174:3013/api/seat/findName",
        data: {'classId': 2},
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
    return null;
  }
}
