import 'package:flutter/material.dart';
import 'package:lastdance_f/model/alert_model.dart';
import 'package:lastdance_f/screen/noticeDetail.dart';

class EndDrawerWidget extends StatefulWidget {
  final int classId;
  final int studentId;

  const EndDrawerWidget({super.key, required this.classId, required this.studentId});

  @override
  State<EndDrawerWidget> createState() => _EndDrawerWidgetState();
}

class _EndDrawerWidgetState extends State<EndDrawerWidget> {
  final AlertModel _alertModel = AlertModel();
  List<dynamic> alertList = [];

  @override
  void initState() {
    super.initState();
    _loadAlert();
  }

  void _loadAlert() async {
    List<dynamic> alertData = await _alertModel.searchAlert(widget.classId, widget.studentId);
    setState(() {
      alertList = alertData;
    });
  }

  void _updateAlert(int alertId) async {
    await _alertModel.updateAlert(alertId);
    _loadAlert();
  }

  List<String> notifications = [];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text(
              '알림 리스트',
              style: TextStyle(fontSize: 24),
            ),
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
              ListTile(
                title: Text(
                  alert["alertCategory"] == "공지사항"
                      ? '알림: ${alert["alertCategory"]}이 작성 되었습니다'
                      : '알림: ${alert["alertCategory"]}가 시작되었습니다',
                ),
                subtitle: Text("${alert["noticeId"]}번 공지사항"),
                onTap: () {
                  Navigator.pop(context);
                  _updateAlert(alert['alertId']);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              NoticeDetailpage(noticeId: alert["noticeId"])));
                },
              ),
        ],
      ),
    );
  }
}
