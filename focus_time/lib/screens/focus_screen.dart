import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/session_model.dart';
import '../services/storage_service.dart';

const platform = MethodChannel('focus_mode/dnd');

class FocusScreen extends StatefulWidget {
  final int durationMinutes;

  const FocusScreen({super.key, required this.durationMinutes});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late int _remainingSeconds;
  Timer? _timer;
  Timer? _postAlarmTimer;

  bool _isAlarmPlaying = false;
  bool _sessionSaved = false;
  bool _hasTimerEnded = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    platform.invokeMethod('enableDND');

    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _postAlarmTimer?.cancel();
    _audioPlayer.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    platform.invokeMethod('disableDND');
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
  }

  void playAlarm() async {
    debugPrint("🔔 Alarm triggered");

    setState(() => _isAlarmPlaying = true);

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('alarm.mp3'));
      debugPrint("✅ Alarm playing");
    } catch (e) {
      debugPrint("❌ Failed to play alarm: $e");
    }

    await _saveSession(widget.durationMinutes);

    _postAlarmTimer = Timer(const Duration(seconds: 30), () {
      if (_isAlarmPlaying) {
        stopSession();
      }
    });
  }

  Future<void> _saveSession(int minutes) async {
    if (_sessionSaved || minutes <= 0) return;

    _sessionSaved = true;

    await StorageService.saveSession(
      SessionModel(dateTime: DateTime.now(), durationMinutes: minutes),
    );

    debugPrint("📝 Session saved: $minutes min");
  }

  void stopSession() async {
    debugPrint("🛑 Stopping session");

    if (_isAlarmPlaying) {
      await _audioPlayer.stop();
      setState(() => _isAlarmPlaying = false);
    }

    _timer?.cancel();
    _postAlarmTimer?.cancel();

    if (!_sessionSaved) {
      int focusedMinutes = _hasTimerEnded
          ? widget.durationMinutes
          : _calculateElapsedMinutes();
      await _saveSession(focusedMinutes);
    }

    if (mounted) Navigator.pop(context);
  }

  int _calculateElapsedMinutes() {
    int secondsElapsed = widget.durationMinutes * 60 - _remainingSeconds;
    return (secondsElapsed / 60).floor();
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
