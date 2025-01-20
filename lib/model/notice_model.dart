import 'package:dio/dio.dart';

class NoticeModel {

  Future<List<dynamic>> searchNotice({String? category}) async {
    final dio = Dio();
    try {
      final response = await dio.get(
        "http://112.221.66.174:6892/api/notice/view",
        queryParameters: {
          'classId': 1,
          if (category != null) 'noticeCategory': category,
        },
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception("Error: $e");
    }
  }


  Future<List<dynamic>> searchNoticeDetail(int noticeId) async {
    final dio = Dio();
    try {
      final response = await dio.
      get(
        "http://112.221.66.174:6892/api/notice/detail/$noticeId",
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}