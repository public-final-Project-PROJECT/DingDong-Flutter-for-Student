import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lastdance_f/model/alert_model.dart';
import 'package:lastdance_f/screen/notice.dart';
import 'package:lastdance_f/screen/noticeDetail.dart';
import 'package:lastdance_f/screen/vote.dart';

class EndDrawerWidget extends StatefulWidget {
  const EndDrawerWidget({super.key});

  @override
  _EndDrawerWidgetState createState() => _EndDrawerWidgetState();
}

class _EndDrawerWidgetState extends State<EndDrawerWidget> {
  AlertModel _alertModel = AlertModel();
  List<dynamic> alertList = [];

  @override
  void initState() {
    super.initState();
    _loadAlert();
  }

  void _loadAlert() async {
    List<dynamic> AlertData = await _alertModel.searchAlert();
    setState(() {
      alertList = AlertData;
      print(alertList);
    });
  }

  void _updateAlert(int alertId) async {
    await _alertModel.updateAlert(alertId);
    _loadAlert();
  }

  String formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      DateTime kstDateTime = dateTime.add(Duration(hours: 9));
      return DateFormat("MM월 dd일 HH시 mm분").format(kstDateTime);
    } catch (e) {
      return "날짜 형식 오류";
    }
  }

  Future<String> votingNameData(int votingId) async {
    final result = await _alertModel.votingNameSearch(votingId);

    if (result is String) {
      return result.toString(); // 문자열인 경우 바로 반환
    } else if (result is List && result.isNotEmpty) {
      return result[0].toString(); // 리스트에서 첫 번째 항목 추출
    } else {
      throw Exception("유효하지 않은 데이터 형식: $result");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child:
            Row(
          children: [
            Icon(Icons.add_alert_sharp, color: Colors.orange, size: 40,),
            SizedBox(width: 7,),
            Text(
              '알림 리스트',
              style: TextStyle(fontSize: 24),
            ),
        ],
      )

          ),
          if (alertList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '알림이 없습니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            for (var alert in alertList)
              Column(
                children: [
                  if (alert["alertCategory"] == "공지사항")
                    ListTile(
                      title: Row(
                        children: [
                          const SizedBox(width: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.deepOrangeAccent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.message,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 5),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert["alertCategory"] == "공지사항"
                                      ? ' ${alert["alertCategory"]}이 작성 되었습니다'
                                      : ' ${alert["alertCategory"]}가 시작되었습니다',
                                  style: const TextStyle(fontSize: 13),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "${alert["noticeId"]}번 공지사항",
                                  style: const TextStyle(fontSize: 13),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  formatDate(alert["alertAt"]),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      onTap: () {
                        print(alert['noticeId']);
                        Navigator.pop(context);
                        _updateAlert(alert['alertId']);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoticeDetailpage(
                                noticeId: alert["noticeId"]),
                          ),
                        );
                      },
                    ),
                  if (alert["alertCategory"] == "투표재촉" ||
                      alert["alertCategory"] == "투표결과")
                    FutureBuilder<String>(
                      future: votingNameData(alert["votingId"]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            title: Text("로딩 중..."),
                          );
                        } else if (snapshot.hasError) {
                          return const ListTile(
                            title: Text("투표 이름을 불러오는 데 실패했습니다."),
                          );
                        } else {
                          return ListTile(
                            title: Row(
                              children: [
                                const SizedBox(width: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrangeAccent,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.how_to_vote_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 5),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (alert["alertCategory"] == "투표재촉")
                                        Row(
                                          children: [
                                            Text(
                                              "< ${snapshot.data} >",
                                              style: const TextStyle(fontSize: 15),
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis
                                            ),
                                            Text(
                                              " 에 투표해주세요 !",
                                              style: const TextStyle(fontSize: 14),
                                                softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        )
                                      else if (alert["alertCategory"] ==
                                          "투표결과")

                                        Row(
                                          children: [
                                            Text(
                                              "< ${snapshot.data} >",
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                " 투표가 종료되었습니다 !",
                                                style: const TextStyle(fontSize: 14),
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),

                                      SizedBox(width: 5),
                                      Text(
                                        formatDate(alert["alertAt"]),
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _updateAlert(alert['alertId']);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Vote()),
                              );
                            },
                          );
                        }
                      },
                    ),
                  const Divider(
                    color: Colors.grey,
                  ),
                ],
              ),
        ],
      ),
    );
  }
  }

