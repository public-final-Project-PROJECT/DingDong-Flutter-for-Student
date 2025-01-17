
import 'package:dio/dio.dart';

class AlertModel {
  Future<List<dynamic>> searchAlert() async{
    final dio = Dio();
    try{
      final response = await dio.get( "http://112.221.66.174:6892/api/alert/view",
        queryParameters: {
          'classId': 7,
          'studentId': 2,
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
      await dio.get( "http://112.221.66.174:6892/api/alert/update",
        queryParameters: {
          'alertId': alert,
        },
      );
    }catch (e) {
      throw Exception("Error: $e");
    }
  }

}