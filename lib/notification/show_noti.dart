//알림 설정
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lastdance_f/notification/init_noti.dart';

showNotification(String? title,String? content) async{
  //안드로이드 알림 설정
  //특정 알림 채널에 등록해줘야한다
  var androidDetails = AndroidNotificationDetails(
    "test_id",
    "테스트채널",
    priority: Priority.max,  //Priority 우선순위 ex) 여러개 울릴 시 우선순위
    color: Colors.black,
  );

  //애플
  var iosDetails = DarwinNotificationDetails(
    presentAlert: true, // 알림이 표시될때 팝업 보여줄지
    presentBadge: true, // 아이콘
    presentSound: true,
  );

  //id, title, body, notificationDetails
  notifications.show(1,
      title, content
      ,NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: "test_payload");

}