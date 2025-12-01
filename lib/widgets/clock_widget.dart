import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'clock_painter.dart';

class ClockWidget extends StatelessWidget {
  final DateTime currentTime;
  final List<TaskModel> tasks;

  const ClockWidget({
    super.key,
    required this.currentTime,
    required this.tasks,
  });

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hour = currentTime.hour % 12;
    final minute = currentTime.minute;
    final hourAngle = (hour * 30 + minute * 0.5) * (3.14159 / 180); // Convert to radians
    final minuteAngle = minute * 6 * (3.14159 / 180); // Convert to radians

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Clock face dengan RepaintBoundary untuk optimasi
            RepaintBoundary(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: ClockPainter(
                      hourAngle: hourAngle,
                      minuteAngle: minuteAngle,
                      tasks: tasks,
                    ),
                  ),
                ),
              ),
            ),
            // Time display real-time di pojok kiri atas
            Positioned(
              top: 12,
              left: 12,
              child: Text(
                _formatTime(currentTime),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

