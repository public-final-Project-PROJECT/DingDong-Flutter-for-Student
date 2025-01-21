import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/voting_model.dart';

class Vote extends StatefulWidget {
  final int classId;
  final int studentId;
  const Vote({super.key, required this.classId, required this.studentId});

  @override
  State<Vote> createState() => _StudentVoteState();
}

class _StudentVoteState extends State<Vote> {
  List<dynamic> _voteList = []; // 투표 정보 담기
  Map<int, List<dynamic>> _allVotingData = {}; // 투표 id 별 항목 정보
  List<Map<String, dynamic>> _studentsInfo = []; // 반 학생들의 정보(학생테이블)
  Map<int, Map<int, List<dynamic>>> _votingStudentsMap = {}; // 투표 항목에 대한 학생들 정보

  final VotingModel _votingModel = VotingModel();

  // Map<int, int?> _selectedContents = {};
  Map<int, List<dynamic>> _selectedContents = {};

  @override
  void initState() {
    super.initState();
    _loadVoting(); // 투표 기본정보, 항목 요청
    _loadClassStudentsInfo(); // 학생들의 항목 투표 내용 요청
  }

  // 학생 정보
  void _loadClassStudentsInfo() async {
    try {
      List<dynamic> studentsList = await _votingModel.findStudentsNameAndImg(widget.classId);
      print(' 우리반 학생정보 불러옴 _studentsInfo : $studentsList');
      setState(() {
        _studentsInfo = studentsList.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print("Error loading student info: $e");
    }
  }

  void _loadVoting() async {
    try {
      List<dynamic> votingData = await _votingModel.selectVoting(widget.classId);

      // 진행중인 투표를 위로 배치
      votingData.sort((a, b) {
        if (a["vote"] == true && b["vote"] != true) return -1;
        if (a["vote"] != true && b["vote"] == true) return 1;
        return 0;
      });

      setState(() {
        _voteList = votingData;
      });

      print(' 투표 기본정보 vote_list : $_voteList');

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

  // 알림
  void _showAlertDialog(String title, String content, int votingId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("닫기"),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _voteOptionUsers(votingId);
                });
              },
            ),
          ],
        );
      },
    );
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
      print('학생들 투표 정보 _votingStudentsMap :: $_votingStudentsMap');
    } catch (e) {
      print("Error 학생 투표 정보 api: $e");
    }
  }

  // 투표 항목 조회 api
  void _loadVotingContents(int votingId) async {
    try {
      List<dynamic> contents =
          await _votingModel.selectVotingContents(votingId);
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
      final studentsVotedForContent =
          _votingStudentsMap[votingId]?[contentId] ?? [];
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

  // 투표하기 버튼 handler
  void _submitVote(int votingId) async {
    final selectedContent = _selectedContents[votingId];

    if (selectedContent == null || selectedContent.isEmpty) {
      print("No content selected for voting $votingId");
      return;
    }

    try {
      for (var selectedContentId in selectedContent) {
        final record = await _votingModel.saveVotingRecord(
            selectedContentId, widget.studentId, votingId);
        print("Vote saved for content $selectedContentId: $record");

        if (record == null || record.isEmpty) {
          _showAlertDialog("알림", "투표가 완료되었습니다!", votingId);
        } else {
          _showAlertDialog("경고 알림", "투표 실패!", votingId);
        }
      }

      setState(() {
        _selectedContents[votingId] = selectedContent;
      });
    } catch (e) {
      print("Error saving voting records: $e");
      _showAlertDialog("오류", "투표 저장 중 문제가 발생했습니다!", votingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.how_to_vote, color: Colors.deepOrange, size: 30),
            SizedBox(width: 15),
            Text("학급 투표"),
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
          final votingContents = _allVotingData[votingId] ?? [];
          final mostVotedContent = _getMostVotedContent(votingId);
          final mostVotedContentName = mostVotedContent["votingContents"] ?? "";
          final createdAt = voting["createdAt"] != null
              ? DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(voting["createdAt"]))
              : '';
          final votingEnd = voting["votingEnd"] != null
              ? DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(voting["votingEnd"]))
              : '';
          final studentVotes =
              _votingStudentsMap[votingId]?.values.expand((x) => x).toList() ??
                  [];
          final isVoted =
              studentVotes.any((vote) => vote["studentId"] == widget.studentId);
          final myVote = studentVotes.firstWhere(
            (vote) => vote["studentId"] == widget.studentId,
            orElse: () => null,
          );

          // 중복투표 여부 확인
          final doubleVoting = voting["doubleVote"] ?? false;

          return Card(
              margin: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: voting["vote"] == true ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 13),
                                  if (voting["anonymousVote"] == false)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: voting["vote"] == false
                                            ? Colors.grey
                                            : Colors.deepOrangeAccent,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Text(
                                        "비밀 투표",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  // 중복투표 표시
                                  if (doubleVoting == true)
                                    Stack(
                                      children: [
                                        Container(
                                          padding:
                                          EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: voting["vote"] == false
                                                ? Colors.grey
                                                : Colors.orangeAccent,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Text(
                                            "중복투표",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Text(
                                voting["votingName"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19,
                                ),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 25),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.deepOrangeAccent,
                              size: 20,
                            ),
                            SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                voting["votingDetail"] ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.deepOrangeAccent,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18),
                        if (mostVotedContentName.isNotEmpty) SizedBox(height: 30),
                        if (voting["vote"] == false)
                          Text(
                            mostVotedContentName,
                            style: TextStyle(
                              color: Colors.deepOrangeAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: votingContents.map<Widget>((content) {
                              bool isVoted = false; // Ensure it's initialized to false or true.
                              final contentId = content["contentsId"];
                              final isMyVote =
                                  myVote != null && myVote["contentsId"] == contentId;
                              final voteCount =
                                  _votingStudentsMap[votingId]?[contentId]?.length ?? 0;

                              return ListTile(
                                leading: Radio<int>(
                                  value: contentId,
                                  groupValue:
                                  _selectedContents[votingId]?.isNotEmpty ?? false
                                      ? _selectedContents[votingId]!.last
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      if (doubleVoting) {
                                        if (_selectedContents[votingId] == null) {
                                          _selectedContents[votingId] = [];
                                        }
                                        if (!_selectedContents[votingId]!.contains(value)) {
                                          _selectedContents[votingId]!.add(value);
                                        }
                                      } else {
                                        _selectedContents[votingId] = [value];
                                      }
                                    });
                                  },
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        content["votingContents"] ?? "",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: isMyVote ? Colors.red : Colors.black,
                                        ),
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                    if (voting["anonymousVote"] == true && isVoted == true)
                                      Text(
                                        " ($voteCount명)",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (voting["votingEnd"] != null)
                            Row(
                              children: [
                                Icon(Icons.alarm, size: 22, color: Colors.red),
                                SizedBox(width: 5),
                                Text(
                                  votingEnd,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  "  종료 !",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                SizedBox(height: 20)
                              ],
                            )
                          else
                            SizedBox(height: 30),
                          TextButton(
                            onPressed: isVoted || voting["vote"] == false
                                ? null
                                : () => _submitVote(votingId),
                            style: TextButton.styleFrom(
                              backgroundColor: isVoted || voting["vote"] == false
                                  ? Colors.grey
                                  : Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding:
                              EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outlined,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  isVoted ? "이미 투표 완료" : "투표하기",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
