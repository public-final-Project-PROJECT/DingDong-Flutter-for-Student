import 'package:dio/dio.dart';

class VotingModel {
  // 투표 list 조회
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
      print(e);
      throw Exception("Error : $e");
    }
  }

  // 각 투표 항목들조회
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
      print(e);
      throw Exception("Error : $e");
    }
  }

  // 새 투표 생성
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
      print("Error: $e");
      throw Exception("Error: $e");
    }
  }





  // 학생정보 가져오기 (이름, 이미지)
    Future <List<dynamic>> findStudentsNameAndImg(int classId) async{
        final dio = Dio();

        try{
          final response = await dio.post(
            "http://112.221.66.174:3013/api/voting/findStudentsName",
            data: {'classId' : 2},
          );
          if(response.statusCode == 200){
            print(response.data);
            return response.data as List<dynamic>;
          }else{
            throw Exception("로드 실패");
          }
        }catch(e) {
          print(e);
          throw Exception("Error : $e");
        }
    }

    // 투표 항목들에 대한 학생들의 투표 정보들
    Future<List<dynamic>> voteOptionUsers(int voteId) async {
      final dio = Dio();

      try{
        final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/VoteOptionUsers",
          data: {'votingId' : voteId}
        );
        if(response.statusCode == 200){
          return response.data as List<dynamic>;
        }else{
          throw Exception("로드 실패");
        }
      }catch(e) {
       print(e);
       throw Exception(e);
      }
    }


    // 투표 종료 api
  Future<List<dynamic>> isVoteUpdate(int voteId) async {
    final dio = Dio();
    print('종료 투표 id :  + $voteId');

    try{
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/isVoteUpdate",
          data: {'votingId' : voteId}
      );
      if(response.statusCode == 200){
        return response.data as List<dynamic>;
      }else{
        throw Exception("로드 실패");
      }
    }catch(e) {
      print(e);
      throw Exception(e);
    }
  }

  // 투표 삭제
  Future<List<dynamic>> deleteVoting(int voteId) async {
    final dio = Dio();

    try{
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/deleteVoting",
          data: {'votingId' : voteId}
      );
      if(response.statusCode == 200){
        return response.data as List<dynamic>;
      }else{
        throw Exception("로드 실패");
      }
    }catch(e) {
      print(e);
      throw Exception(e);
    }
  }

  // studentsName 이랑 img 랑 id 가지고와서 찍어주는 부분
  Future<bool> findByVotingIdForStdInfoTest(int voteId) async {
    final dio = Dio();

    try{
      final response = await dio.post(
          "http://112.221.66.174:3013/api/voting/findByVotingIdForStdInfoTest",
          data: {'votingId' : voteId}
      );
      if(response.statusCode == 200){
        print(response.data);
        return response.data as bool;
      }else{
        throw Exception("로드 실패");
      }
    }catch(e) {
      print(e);
      throw Exception(e);
    }
  }

  // 학생 투표 기록 저장
  Future<List<dynamic>?> saveVotingRecord(int contentsId, int studentId, int votingId) async {
    final dio = Dio();
    print('record 기록 넘어온 값 : $contentsId , $studentId , $votingId ');

    try {
      final response = await dio.post(
        "http://112.221.66.174:3013/api/voting/uservoteinsert",
        data: {'contentsId': contentsId, 'studentId': studentId, 'votingId': votingId},
      );
      if (response.statusCode == 200) {
        print("응답 데이터: ${response.data}");
        // 데이터가 List인지 확인
        if (response.data is List<dynamic>) {
          return response.data as List<dynamic>;
        } else {
          // 데이터가 bool인 경우 처리
          if (response.data == true) {
            return []; // 성공으로 간주하고 빈 리스트 반환
          } else {
            throw Exception("투표 저장 실패 (응답: ${response.data})");
          }
        }
      } else {
        throw Exception("로드 실패");
      }
    } catch (e) {
      print("API 호출 에러: $e");
      throw Exception(e);
    }
  }

}
