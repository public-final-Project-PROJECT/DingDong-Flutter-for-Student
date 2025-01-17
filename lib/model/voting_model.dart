import 'package:dio/dio.dart';

class VotingModel {
  Future<List<dynamic>> selectVoting(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/findVoting",
          data: {'classId': 2});

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
  }

  Future<List<dynamic>> selectVotingContents(int votingId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/findContents",
          data: {'votingId': votingId});

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
  }

  Future<List<dynamic>> newVoting(
      String title,
      String description,
      List<dynamic> options,
      String? deadline,
      bool secretVoting,
      bool doubleVoting) async {
    final dio = Dio();
    try {
      if (deadline == null || deadline.isEmpty) {
        deadline = "no";
      }

      final response = await dio.post(
        "http://112.221.66.174:3013/api/voting/newvoting",
        data: {
          'classId': 2,
          'votingName': title,
          'detail': description,
          'votingEnd': deadline,
          'contents': options,
          'anonymousVote': secretVoting,
          'doubleVote': doubleVoting,
        },
      );

      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<List<dynamic>> findStudentsNameAndImg(int classId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        "http://112.221.66.174:3013/api/voting/findStudentsName",
        data: {'classId': 2},
      );
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception("Error : $e");
    }
  }

  Future<List<dynamic>> voteOptionUsers(int voteId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/VoteOptionUsers",
          data: {'votingId': voteId});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<dynamic>> isVoteUpdate(int voteId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/isVoteUpdate",
          data: {'votingId': voteId});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<dynamic>> deleteVoting(int voteId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/deleteVoting",
          data: {'votingId': voteId});
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> findByVotingIdForStdInfoTest(int voteId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/findByVotingIdForStdInfoTest",
          data: {'votingId': voteId});
      if (response.statusCode == 200) {
        return response.data as bool;
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<dynamic>?> saveVotingRecord(
      int contentsId, int studentId, int votingId) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        "http://112.221.66.174:3013/api/voting/uservoteinsert",
        data: {
          'contentsId': contentsId,
          'studentId': studentId,
          'votingId': votingId
        },
      );
      if (response.statusCode == 200) {
        if (response.data is List<dynamic>) {
          return response.data as List<dynamic>;
        } else {
          if (response.data == true) {
            return [];
          } else {
            throw Exception("투표 저장 실패 (응답: ${response.data})");
          }
        }
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
