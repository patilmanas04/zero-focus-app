import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void alarmCallback() {
  _showAlarmNotification();
}

void _showAlarmNotification() async {
  const androidDetails = AndroidNotificationDetails(
    'alarm_channel_id',
    'Focus Alarm',
    channelDescription: 'Rings when focus session ends',
    importance: Importance.max,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound(
      'alarm',
    ), // alarm.mp3 must be in android/app/src/main/res/raw
    playSound: true,
    enableVibration: true,
  );

  const notificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    '⏰ Focus Session Ended',
    'Time to take a break!',
    notificationDetails,
  );
}
