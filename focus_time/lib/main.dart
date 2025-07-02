import 'package:flutter/material.dart';
import 'package:focus_time/screens/home_screen.dart';

void main() async {
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
