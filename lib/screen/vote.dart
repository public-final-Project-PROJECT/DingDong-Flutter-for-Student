import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/voting_model.dart';

class Vote extends StatefulWidget {
  const Vote({super.key});

  @override
  State<Vote> createState() => _StudentVoteState();
}

class _StudentVoteState extends State<Vote> {
  List<dynamic> _voteList = []; // 투표 정보 담기
  Map<int, List<dynamic>> _allVotingData = {}; // 투표 id 별 항목 정보
  List<Map<String, dynamic>> _studentsInfo = []; // 반 학생들의 정보(학생테이블)
  Map<int, Map<int, List<dynamic>>> _votingStudentsMap = {};
  // 투표 항목에 대한 학생들 정보

  int classId = 2;
  int studentId = 33; // 내 학생 고유 번호

  final VotingModel _votingModel = VotingModel();

  @override
  void initState() {
    super.initState();
    _loadVoting(); // 투표 기본정보, 항목 요청
    _loadClassStudentsInfo(classId); // 학생들의 항목 투표 내용 요청
  }

  // 학생 정보
  void _loadClassStudentsInfo(int classId) async {
    try {
      List<dynamic> studentsList = await _votingModel.findStudentsNameAndImg(2);
      setState(() {
        _studentsInfo = studentsList.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Error loading student info: $e");
    }
  }

  void _loadVoting() async {
    try {
      List<dynamic> votingData = await _votingModel.selectVoting(1);

      // 진행중인 투표를 위로 배치
      votingData.sort((a, b) {
        if (a["vote"] == true && b["vote"] != true) return -1;
        if (a["vote"] != true && b["vote"] == true) return 1;
        return 0;
      });

      setState(() {
        _voteList = votingData;
      });

     // 투표 contents 조회
      for (var voting in votingData) {
        final votingId = voting["id"];
        if (votingId != null) {
          _loadVotingContents(votingId);
          _voteOptionUsers(votingId); // 학생들의 항목 투표 정보
        }
      }
    } catch (e) {
      print("Error loading voting data: $e");
    }
  }

  // 투표 항목에 대한 학생들의 투표 정보 api
  void _voteOptionUsers(int votingId) async {
    try {
      List<dynamic> userVotingData =
      await _votingModel.voteOptionUsers(votingId);
      Map<int, List<dynamic>> votingStudents = {};
      print(userVotingData);
      for (var userVote in userVotingData) {
        final int contentsId = userVote["contentsId"];
        if (!votingStudents.containsKey(contentsId)) {
          votingStudents[contentsId] = [];
        }
        votingStudents[contentsId]!.add(userVote);
      }
      setState(() {
        _votingStudentsMap[votingId] = votingStudents;
      });
      print(_votingStudentsMap);
    } catch (e) {
      print("Error 학생 투표 정보 api: $e");
    }
  }

  // 투표 항목 조회 api
  void _loadVotingContents(int votingId) async {
    try {
      List<dynamic> contents = await _votingModel.selectVotingContents(votingId);
      setState(() {
        _allVotingData[votingId] = contents;
      });
    } catch (e) {
      print("Error loading voting contents for $votingId: $e");
    }
  }

  // 가장 득표수가 많은 항목 조회 함수
  Map<String, dynamic> _getMostVotedContent(int votingId) {
    final votingContents = _allVotingData[votingId] ?? [];
    Map<int, int> voteCounts = {};

    for (var content in votingContents) {
      final contentId = content["contentsId"];
      final studentsVotedForContent = _votingStudentsMap[votingId]?[contentId] ?? [];
      voteCounts[contentId] = studentsVotedForContent.length;
    }

    int maxVotes = 0;
    int mostVotedContentId = -1;
    voteCounts.forEach((contentId, count) {
      if (count > maxVotes) {
        maxVotes = count;
        mostVotedContentId = contentId;
      }
    });

    if (mostVotedContentId != -1) {
      final mostVotedContent = votingContents.firstWhere(
            (content) => content["contentsId"] == mostVotedContentId,
        orElse: () => {},
      );
      return mostVotedContent;
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("학급 투표"),
            SizedBox(width: 15),
            Icon(Icons.how_to_vote),
          ],
        ),
        backgroundColor: const Color(0xffF4F4F4),
        shape: const Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      backgroundColor: const Color(0xffF4F4F4),
      body: ListView.builder(
        itemCount: _voteList.length,
        itemBuilder: (context, index) {
          final voting = _voteList[index];
          final votingId = voting["id"];
          final votingContents = _allVotingData[votingId] ?? []; // 항목 정보
          final mostVotedContent = _getMostVotedContent(votingId); // 가장 많은 득표수
          final mostVotedContentName = mostVotedContent["votingContents"] ?? "";
          // 생성 시간
          final createdAt = voting["createdAt"] != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(voting["createdAt"]))
              : '';
          // 종료 시간
          final votingEnd = voting["votingEnd"] != null
              ? DateFormat('yyyy-MM-dd').format(DateTime.parse(voting["votingEnd"]))
              : '';

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 13,
                              color: voting["vote"] == true ? Colors.red : Colors.grey,
                            ),
                            SizedBox(width: 5),
                            Text(
                              voting["vote"] == true ? "진행중" : "종료",
                              style: TextStyle(
                                fontSize: 15,
                                color: voting["vote"] == true ? Colors.red : Colors.grey,
                              ),
                            ),
                            if (voting["votingEnd"] != null && voting["vote"] == true)
                              Row(
                                children: [
                                  Icon(Icons.hourglass_bottom, color: Colors.redAccent),
                                  Text(
                                    votingEnd,
                                    style: TextStyle(fontSize: 12, color: Colors.red),
                                  ),
                                  Text(
                                    " 에 자동으로 종료됩니다!",
                                    style: TextStyle(fontSize: 14, color: Colors.red),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.offline_pin_rounded, color: Color(0xffb3a724),),
                            SizedBox(width: 5),
                            Text(
                              voting["votingName"] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(voting["votingDetail"] ?? ''),
                  if (mostVotedContentName.isNotEmpty) SizedBox(height: 30),
                  Row(
                    children: [
                      Icon(Icons.how_to_vote_rounded),
                      SizedBox(width: 5),
                      if (voting["vote"] == false)
                        Row(
                          children: [
                            Text(
                              "투표 결과: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              mostVotedContentName,
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            ...votingContents.map((content) {
                              return Row(
                                children: [
                                  Radio(
                                    value: content["contentsId"],
                                    groupValue: voting["selectedContentId"],
                                    onChanged: (value) {
                                      setState(() {
                                        voting["selectedContentId"] = value;
                                      });
                                    },
                                  ),
                                  Text(content["votingContents"] ?? ""),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      createdAt,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),

            ),
          );
        },
      ),
    );
  }
}
