import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class ClockPainter extends CustomPainter {
  final double hourAngle;
  final double minuteAngle;
  final List<TaskModel> tasks;

  ClockPainter({
    required this.hourAngle,
    required this.minuteAngle,
    required this.tasks,
  });

  // Helper function to check if two time ranges overlap
  bool _doTimeRangesOverlap(
    int start1, int end1,
    int start2, int end2,
  ) {
    // Handle wrap-around (e.g., 11 PM to 1 AM)
    if (end1 < start1) end1 += 720; // Add 12 hours in minutes
    if (end2 < start2) end2 += 720;
    
    return (start1 < end2 && end1 > start2) ||
           (start2 < end1 && end2 > start1);
  }

  // Helper function to count overlapping tasks for a given task
  int _countOverlaps(List<TaskModel> activeTasks, int currentIndex) {
    if (activeTasks[currentIndex].alarmTime == null || 
        activeTasks[currentIndex].duration == null) {
      return 0;
    }
    
    final currentStartParts = activeTasks[currentIndex].alarmTime!.split(':');
    final currentStartHour = int.parse(currentStartParts[0]);
    final currentStartMinute = int.parse(currentStartParts[1]);
    final currentDurationParts = activeTasks[currentIndex].duration!.split(':');
    final currentDurationHour = int.parse(currentDurationParts[0]);
    final currentDurationMinute = int.parse(currentDurationParts[1]);
    
    final currentStart = (currentStartHour % 12) * 60 + currentStartMinute;
    final currentEnd = currentStart + currentDurationHour * 60 + currentDurationMinute;
    
    int overlapCount = 0;
    for (int i = 0; i < activeTasks.length; i++) {
      if (i == currentIndex) continue;
      if (activeTasks[i].alarmTime == null || activeTasks[i].duration == null) continue;
      
      final otherStartParts = activeTasks[i].alarmTime!.split(':');
      final otherStartHour = int.parse(otherStartParts[0]);
      final otherStartMinute = int.parse(otherStartParts[1]);
      final otherDurationParts = activeTasks[i].duration!.split(':');
      final otherDurationHour = int.parse(otherDurationParts[0]);
      final otherDurationMinute = int.parse(otherDurationParts[1]);
      
      final otherStart = (otherStartHour % 12) * 60 + otherStartMinute;
      final otherEnd = otherStart + otherDurationHour * 60 + otherDurationMinute;
      
      if (_doTimeRangesOverlap(currentStart, currentEnd, otherStart, otherEnd)) {
        overlapCount++;
      }
    }
    return overlapCount;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Filter active tasks (not completed)
    final activeTasks = tasks.where((task) => 
      !task.isCompleted && 
      task.alarmTime != null && 
      task.duration != null
    ).toList();

    // Draw segments based on tasks (hanya untuk task yang belum selesai)
    for (int index = 0; index < activeTasks.length; index++) {
      final task = activeTasks[index];
      
      // Parse start time
      final startParts = task.alarmTime!.split(':');
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      
      // Parse duration
      final durationParts = task.duration!.split(':');
      final durationHour = int.parse(durationParts[0]);
      final durationMinute = int.parse(durationParts[1]);
      
      // Calculate start angle (12 o'clock is -90 degrees / -π/2)
      final startAngle = ((startHour % 12) * 30 + startMinute * 0.5 - 90) * (math.pi / 180);
      
      // Calculate duration in minutes
      final totalDurationMinutes = durationHour * 60 + durationMinute;
      // Convert to angle (360 degrees = 12 hours = 720 minutes)
      final durationAngle = (totalDurationMinutes / 720) * 2 * math.pi;
      
      // Count overlaps untuk menentukan opacity
      final overlapCount = _countOverlaps(activeTasks, index);
      // Semakin banyak overlap, semakin rendah opacity (minimal 0.4)
      final baseOpacity = 1.0 - (overlapCount * 0.15);
      final adjustedOpacity = baseOpacity.clamp(0.4, 1.0);
      
      // Create segment path
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
      
      // Create radial gradient dengan opacity yang disesuaikan
      final taskColor = Color(task.color);
      final gradient = RadialGradient(
        center: Alignment.center,
        stops: const [0.0, 1.0],
        colors: [
          taskColor.withOpacity(adjustedOpacity), // Stop pertama dengan opacity dinamis
          taskColor.withOpacity(adjustedOpacity * 0.3), // Stop kedua: 30% dari opacity dinamis
        ],
      );
      
      // Create shader for the gradient
      final shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
      
      // Draw segment with radial gradient
      final segmentPaint = Paint()
        ..shader = shader
        ..style = PaintingStyle.fill;
      
      canvas.drawPath(segmentPath, segmentPaint);
      
      // Draw border untuk segment agar tetap terlihat meski overlap
      final borderPaint = Paint()
        ..color = taskColor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      canvas.drawPath(segmentPath, borderPaint);
    }

    // Draw clock numbers 1-12
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 12; i++) {
      final angle = (i * 30 - 90) * (math.pi / 180); // Convert to radians
      final x = center.dx + (radius - 20) * math.cos(angle);
      final y = center.dy + (radius - 20) * math.sin(angle);

      textPainter.text = TextSpan(
        text: i.toString(),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw minute hand (long hand)
    final minuteHandPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final minuteHandLength = radius * 0.7;
    final minuteHandEndX = center.dx + minuteHandLength * math.sin(minuteAngle);
    final minuteHandEndY = center.dy - minuteHandLength * math.cos(minuteAngle);
    canvas.drawLine(
      center,
      Offset(minuteHandEndX, minuteHandEndY),
      minuteHandPaint,
    );

    // Draw hour hand (short hand)
    final hourHandPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final hourHandLength = radius * 0.5;
    final hourHandEndX = center.dx + hourHandLength * math.sin(hourAngle);
    final hourHandEndY = center.dy - hourHandLength * math.cos(hourAngle);
    canvas.drawLine(
      center,
      Offset(hourHandEndX, hourHandEndY),
      hourHandPaint,
    );

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    // Check if hour or minute changed (for clock hands)
    if (oldDelegate.hourAngle != hourAngle || 
        oldDelegate.minuteAngle != minuteAngle) {
      return true;
    }
    
    // Check if tasks changed
    if (oldDelegate.tasks.length != tasks.length) return true;
    
    // Check if any task properties changed (isCompleted, alarmTime, duration, color)
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

