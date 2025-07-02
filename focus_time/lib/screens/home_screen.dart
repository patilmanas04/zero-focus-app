import 'package:flutter/material.dart';
import 'dart:ui';
import 'focus_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Custom painter for dotted border
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final bool isSelected;

  _DottedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final RRect rRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    const double dashWidth = 3;
    const double dashSpace = 4;
    final Path path = Path()..addRRect(rRect);
    final pathMetrics = path.computeMetrics();

    for (final PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double next = distance + dashWidth;
        canvas.drawPath(pathMetric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        borderRadius != oldDelegate.borderRadius ||
        isSelected != oldDelegate.isSelected;
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedMinutes = 30;

  final List<int> focusDurations = [1, 5, 10, 15, 25, 30, 45, 60];

  void startFocusSession() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FocusScreen(durationMinutes: selectedMinutes),
      ),
    );
  }

  Widget buildMinuteButton(int min) {
    final bool isSelected = selectedMinutes == min;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMinutes = min;
        });
      },
      child: Container(
        width: 70,
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: isSelected
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$min',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'JetBrainsMono',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MIN',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              )
            : CustomPaint(
                painter: _DottedBorderPainter(
                  color: Colors.black,
                  borderRadius: 12,
                  isSelected: false,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$min',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'JetBrainsMono',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MIN',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Zero.',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
            fontSize: 25,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text('SELECT DURATION', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: focusDurations.map(buildMinuteButton).toList(),
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${selectedMinutes.toString().padLeft(2, '0')}:00',
                  style: const TextStyle(
                    fontSize: 70,
                    fontFamily: "Orbitron",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'MINUTES SELECTED',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: startFocusSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.timer_outlined, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'START FOCUS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
