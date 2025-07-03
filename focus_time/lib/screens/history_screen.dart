import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/session_model.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<SessionModel> sessions = [];

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final data = await StorageService.getSessions();
    setState(() => sessions = data);
  }

  double get totalMinutes =>
      sessions
              .fold(0.0, (sum, s) => sum + s.coveredMinutes / 60)
              .toStringAsFixed(1) ==
          '0.0'
      ? 0.0
      : double.parse(
          sessions
              .fold(0.0, (sum, s) => sum + s.coveredMinutes / 60)
              .toStringAsFixed(1),
        );

  double get completionRate {
    if (sessions.isEmpty) return 0.0;
    final completedSessions = sessions
        .where((s) => (s.coveredMinutes / s.totalDuration) * 100 == 100)
        .length;
    if (completedSessions == 0) return 0.0;
    return (completedSessions / sessions.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    void onStartFocus() {
      Navigator.pop(context); // Or navigate to the main timer screen
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FOCUS HISTORY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontFamily: "Orbitron",
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await StorageService.clearHistory();
              setState(() => sessions = []);
            },
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: sessions.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'NO FOCUS SESSIONS YET',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start your first focus session to see it here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: onStartFocus,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black, width: 1.4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'START FOCUSING',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'TOTAL SESSIONS',
                        value: '${sessions.length}',
                      ),
                      _StatColumn(
                        label: 'MINUTES FOCUSED',
                        value: '$totalMinutes',
                      ),
                      _StatColumn(
                        label: 'COMPLETION RATE',
                        value: '${completionRate.toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      debugPrint("Session: ${session.toJson()}");
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Stack(
                          children: [
                            // Matrix background + Card content
                            CustomPaint(
                              // painter: _LineMatrixPainter(),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    // Matrix background inside the card
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _LineMatrixPainter(),
                                      ),
                                    ),
                                    Card(
                                      elevation: 0,
                                      color: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      margin: EdgeInsets.zero,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat(
                                                'dd MMM yyyy • HH:mm',
                                              ).format(session.dateTime),
                                              style: const TextStyle(
                                                fontFamily: 'JetBrainsMono',
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${(session.coveredMinutes / 60).toStringAsFixed(1)} MINS',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontFamily: "Orbitron",
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '${((session.coveredMinutes / session.totalDuration) * 100).toStringAsFixed(1)}%\nof ${session.totalDuration ~/ 60} MINS',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              ((session.coveredMinutes /
                                                              session
                                                                  .totalDuration) *
                                                          100) ==
                                                      100
                                                  ? 'COMPLETED'
                                                  : 'STOPPED EARLY',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    ((session.coveredMinutes /
                                                                session
                                                                    .totalDuration) *
                                                            100) ==
                                                        100
                                                    ? Colors.green
                                                    : Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.1,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for drawing a simple line matrix background
class _LineMatrixPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Draw vertical lines
    for (double x = 0; x < size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
