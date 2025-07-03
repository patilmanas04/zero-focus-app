import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../services/alarm_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/session_model.dart';
import '../services/storage_service.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:wakelock/wakelock.dart';

const platform = MethodChannel('focus_mode/dnd');

class FocusScreen extends StatefulWidget {
  final int durationMinutes;

  const FocusScreen({super.key, required this.durationMinutes});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late int _totalDuration;
  late int _remainingSeconds;
  Timer? _timer;
  Timer? _postAlarmTimer;

  bool _isAlarmPlaying = false;
  // bool _sessionSaved = false;
  bool _hasTimerEnded = false;

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      Wakelock.enable();
    }

    _totalDuration = widget.durationMinutes * 60;
    _remainingSeconds = widget.durationMinutes * 60;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    platform.invokeMethod('enableDND');

    startTimer();
  }

  @override
  void dispose() async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      Wakelock.disable();
    }
    _timer?.cancel();
    _postAlarmTimer?.cancel();
    _audioPlayer.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    platform.invokeMethod('disableDND');
    await _saveSession((_totalDuration - _remainingSeconds), _totalDuration);
    debugPrint("_remainingSeconds: ${_totalDuration - _remainingSeconds}");
    debugPrint("_totalDuration: $_totalDuration");
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _hasTimerEnded = true;
        platform.invokeMethod('disableDND');
        playAlarm();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });

    // Schedule the alarm to fire after duration
    AndroidAlarmManager.oneShot(
      Duration(minutes: 15), // or however long the session is
      1234, // ID of the alarm
      alarmCallback,
      exact: true,
      wakeup: true,
    );
  }

  void playAlarm() async {
    debugPrint("🔔 Alarm triggered");

    await _audioPlayer.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          usageType: AndroidUsageType.alarm,
          contentType: AndroidContentType.music,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );

    setState(() => _isAlarmPlaying = true);

    debugPrint("🔊 Start to Playing alarm sound");

    try {
      debugPrint("Inside try block to play alarm sound");
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('alarm.mp3'));
      debugPrint("✅ Alarm playing");
    } catch (e) {
      debugPrint("❌ Failed to play alarm: $e");
    }

    _postAlarmTimer = Timer(const Duration(seconds: 30), () {
      if (_isAlarmPlaying) {
        stopSession();
      }
    });
  }

  Future<void> _saveSession(int coveredMinutes, int totalDuration) async {
    await StorageService.saveSession(
      SessionModel(
        dateTime: DateTime.now(),
        coveredMinutes: coveredMinutes,
        totalDuration: totalDuration,
      ),
    );

    debugPrint("📝 Session saved: $coveredMinutes min");
  }

  void stopSession() async {
    debugPrint("🛑 Stopping session");

    if (_isAlarmPlaying) {
      await _audioPlayer.stop();
      setState(() => _isAlarmPlaying = false);
    }

    _timer?.cancel();
    _postAlarmTimer?.cancel();

    if (mounted) Navigator.pop(context);
  }

  String formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatTime(_remainingSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontFamily: 'Orbitron',
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: stopSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: const BorderSide(color: Colors.red, width: 2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stop_rounded, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      _isAlarmPlaying ? 'STOP SESSION' : 'CANCEL',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
