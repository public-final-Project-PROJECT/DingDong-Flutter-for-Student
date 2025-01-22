//알림 플러그인 인스턴스 생성
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//알림 플러그인
final FlutterLocalNotificationsPlugin notifications =
FlutterLocalNotificationsPlugin();

initNotification() async{
  //안드로이드 초기화 설정
  //알림 왔을 때 보이는 아이콘
  var androidInitialization = AndroidInitializationSettings("bell");

  //ios 설정  알림 권한 true
  var iosSetting = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  //초기화할 때 등록
  var initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosSetting
  );

  //초기화 실행
  await notifications.initialize(
    initializationSettings,
    // onDidReceiveNotificationResponse 알림 클릭 시 나오는것
    onDidReceiveNotificationResponse: (NotificationResponse response){
      //payload 만약 클릭시 어디로 보낼 수 있다.
    },
  );

  //Android 알림 채널 생성
  var androidChanner = AndroidNotificationChannel(
    "test_id", //채널 id 중복 x
    "테스트채널", //채널 이름
    description: "알림에 대한 설명",
    importance: Importance.max, //알림의 중요도 설정
    playSound: true, //소리설정
    enableVibration: true, //진동 설정
    vibrationPattern: Int64List.fromList([0,1000]),//진동패턴

  );

  //채널 등록
  try{
    await notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChanner);
  }catch(e){
    Exception("테스트 채널 생성 실패 : $e");
  }
}
