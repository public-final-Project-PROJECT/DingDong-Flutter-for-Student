
import 'package:dio/dio.dart';

class AlertModel {
  Future<List<dynamic>> searchAlert(int classId, int studentId) async{
    final dio = Dio();
    try{
      final response = await dio.get( "http://112.221.66.174:3013/api/alert/view",
        queryParameters: {
          'classId': classId,
          'studentId': studentId,
        },
      );
      return response.data as List<dynamic>;
    }catch (e) {
      throw Exception("Error: $e");
    }
  }


  Future<void> updateAlert(int alert) async{
    final dio = Dio();
    try{
      await dio.get( "http://112.221.66.174:3013/api/alert/update",
        queryParameters: {
          'alertId': alert,
        },
      );
    }catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<String> votingNameSearch(int votingId) async {
    final dio = Dio();
    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/votingNameSearch",
          data: {'votingId': votingId});
      if (response.statusCode == 200) {
        return response.data as String;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}