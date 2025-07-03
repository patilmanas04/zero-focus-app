import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:focus_time/screens/home_screen.dart';
import 'package:focus_time/services/alarm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("🟡 Starting App Init...");

  try {
    await AndroidAlarmManager.initialize();
    debugPrint("✅ AlarmManager initialized");
  } catch (e) {
    debugPrint("❌ AlarmManager failed: $e");
  }

  try {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    debugPrint("✅ Notifications initialized");
  } catch (e) {
    debugPrint("❌ Notifications init failed: $e");
  }

  runApp(const FocusModeApp());
}

class FocusModeApp extends StatelessWidget {
  const FocusModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Mode',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "JetBrainsMono",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        scaffoldBackgroundColor: Colors.white,
        // useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
