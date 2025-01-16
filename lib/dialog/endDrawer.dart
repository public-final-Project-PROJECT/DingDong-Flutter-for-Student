import 'package:flutter/material.dart';
import 'package:lastdance_f/model/alert_model.dart';

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
     print("여");
     print(alertList);
     print("여");
   });


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
                title: Text('알림: ${alert["alertCategory"]}'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
        ],
      ),
    );
  }
}