import 'package:flutter/material.dart';
import 'package:lastdance_f/model/alert_model.dart';
import 'package:lastdance_f/screen/notice.dart';
import 'package:lastdance_f/screen/noticeDetail.dart';

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
    _loadAlert();
  }


  void _loadAlert() async {
   List<dynamic> AlertData = await _alertModel.searchAlert();
   setState(() {
     alertList = AlertData;
     print(alertList);
   });
  }

  void _updateAlert(int alertId) async{
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
                  print(alert['noticeId']);
                  Navigator.pop(context);
                  _updateAlert(alert['alertId']);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NoticeDetailpage(noticeId:alert["noticeId"])));
                },
              ),
        ],
      ),
    );
  }
}