import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class ClockPainter extends CustomPainter {
  final double hourAngle;
  final double minuteAngle;

  // ✅ ADDED (optional, boleh null)
  final double? secondAngle;

  final List<TaskModel> tasks;

  ClockPainter({
    required this.hourAngle,
    required this.minuteAngle,
    this.secondAngle, // ← tidak wajib
    required this.tasks,
  });

  // ===============================
  // TIME OVERLAP LOGIC (UNCHANGED)
  // ===============================

  bool _doTimeRangesOverlap(
    int start1, int end1,
    int start2, int end2,
  ) {
    if (end1 < start1) end1 += 720;
    if (end2 < start2) end2 += 720;

    return (start1 < end2 && end1 > start2) ||
        (start2 < end1 && end2 > start1);
  }

  int _countOverlaps(List<TaskModel> activeTasks, int currentIndex) {
    if (activeTasks[currentIndex].alarmTime == null ||
        activeTasks[currentIndex].duration == null) {
      return 0;
    }

    final currentStartParts =
        activeTasks[currentIndex].alarmTime!.split(':');
    final currentStartHour = int.parse(currentStartParts[0]);
    final currentStartMinute = int.parse(currentStartParts[1]);
    final currentDurationParts =
        activeTasks[currentIndex].duration!.split(':');
    final currentDurationHour = int.parse(currentDurationParts[0]);
    final currentDurationMinute =
        int.parse(currentDurationParts[1]);

    final currentStart =
        (currentStartHour % 12) * 60 + currentStartMinute;
    final currentEnd =
        currentStart +
            currentDurationHour * 60 +
            currentDurationMinute;

    int overlapCount = 0;
    for (int i = 0; i < activeTasks.length; i++) {
      if (i == currentIndex) continue;
      if (activeTasks[i].alarmTime == null ||
          activeTasks[i].duration == null) continue;

      final otherStartParts =
          activeTasks[i].alarmTime!.split(':');
      final otherStartHour = int.parse(otherStartParts[0]);
      final otherStartMinute = int.parse(otherStartParts[1]);
      final otherDurationParts =
          activeTasks[i].duration!.split(':');
      final otherDurationHour =
          int.parse(otherDurationParts[0]);
      final otherDurationMinute =
          int.parse(otherDurationParts[1]);

      final otherStart =
          (otherStartHour % 12) * 60 + otherStartMinute;
      final otherEnd =
          otherStart +
              otherDurationHour * 60 +
              otherDurationMinute;

      if (_doTimeRangesOverlap(
          currentStart, currentEnd, otherStart, otherEnd)) {
        overlapCount++;
      }
    }
    return overlapCount;
  }

  // ===============================
  // PAINT
  // ===============================

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final activeTasks = tasks.where((task) =>
        !task.isCompleted &&
        task.alarmTime != null &&
        task.duration != null).toList();

    // ===============================
    // TASK SEGMENTS (UNCHANGED)
    // ===============================
    for (int index = 0; index < activeTasks.length; index++) {
      final task = activeTasks[index];

      final startParts = task.alarmTime!.split(':');
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);

      final durationParts = task.duration!.split(':');
      final durationHour = int.parse(durationParts[0]);
      final durationMinute = int.parse(durationParts[1]);

      final startAngle =
          ((startHour % 12) * 30 + startMinute * 0.5 - 90) *
              (math.pi / 180);

      final totalDurationMinutes =
          durationHour * 60 + durationMinute;
      final durationAngle =
          (totalDurationMinutes / 720) * 2 * math.pi;

      final overlapCount =
          _countOverlaps(activeTasks, index);
      final baseOpacity = 1.0 - (overlapCount * 0.15);
      final adjustedOpacity = baseOpacity.clamp(0.4, 1.0);

      final segmentPath = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + radius * math.cos(startAngle),
          center.dy + radius * math.sin(startAngle),
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          durationAngle,
          false,
        )
        ..close();

      final taskColor = Color(task.color);
      final gradient = RadialGradient(
        colors: [
          taskColor.withOpacity(adjustedOpacity),
          taskColor.withOpacity(adjustedOpacity * 0.3),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        );

      canvas.drawPath(segmentPath, paint);

      canvas.drawPath(
        segmentPath,
        Paint()
          ..color = taskColor.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // ===============================
    // 🔢 CLOCK NUMBERS (IMPROVED)
    // ===============================
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 12; i++) {
      final angle =
          (i * 30 - 90) * (math.pi / 180);

      final position = center +
          Offset(
            math.cos(angle),
            math.sin(angle),
          ) *
              (radius * 0.82); // 🔧 sedikit masuk

      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87, // aman kontras
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        position -
            Offset(
              textPainter.width / 2,
              textPainter.height / 2,
            ),
      );
    }

    // ===============================
    // 🕒 MINUTE HAND (UNCHANGED)
    // ===============================
    final minuteHandLength = radius * 0.7;
    canvas.drawLine(
      center,
      center +
          Offset(
            minuteHandLength * math.sin(minuteAngle),
            -minuteHandLength * math.cos(minuteAngle),
          ),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // ===============================
    // 🕒 HOUR HAND (UNCHANGED)
    // ===============================
    final hourHandLength = radius * 0.5;
    canvas.drawLine(
      center,
      center +
          Offset(
            hourHandLength * math.sin(hourAngle),
            -hourHandLength * math.cos(hourAngle),
          ),
      Paint()
        ..color = Colors.black87
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // ===============================
    // ⏱ SECOND HAND (OPTIONAL)
    // ===============================
    if (secondAngle != null) {
      final secondHandLength = radius * 0.85;
      canvas.drawLine(
        center,
        center +
            Offset(
              secondHandLength * math.sin(secondAngle!),
              -secondHandLength * math.cos(secondAngle!),
            ),
        Paint()
          ..color = Colors.redAccent
          ..strokeWidth = 1.5,
      );
    }

    // Center dot
    canvas.drawCircle(
      center,
      4,
      Paint()..color = Colors.black87,
    );
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    if (oldDelegate.hourAngle != hourAngle ||
        oldDelegate.minuteAngle != minuteAngle ||
        oldDelegate.secondAngle != secondAngle) {
      return true;
    }

    if (oldDelegate.tasks.length != tasks.length) {
      return true;
    }

    for (int i = 0; i < tasks.length; i++) {
      final oldTask = oldDelegate.tasks[i];
      final newTask = tasks[i];

      if (oldTask.isCompleted != newTask.isCompleted ||
          oldTask.alarmTime != newTask.alarmTime ||
          oldTask.duration != newTask.duration ||
          oldTask.color != newTask.color) {
        return true;
      }
    }

    return false;
  }
}
