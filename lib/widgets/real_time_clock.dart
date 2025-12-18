import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'clock_painter.dart';
import '../models/task_model.dart';

class RealTimeClock extends StatefulWidget {
  final List<TaskModel> tasks;

  const RealTimeClock({
    super.key,
    required this.tasks,
  });

  @override
  State<RealTimeClock> createState() => _RealTimeClockState();
}

class _RealTimeClockState extends State<RealTimeClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondAngle =
        (_now.second * 6) * math.pi / 180;

    final minuteAngle =
        (_now.minute * 6 + _now.second * 0.1) *
            math.pi /
            180;

    final hourAngle =
        ((_now.hour % 12) * 30 +
                _now.minute * 0.5) *
            math.pi /
            180;

    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: ClockPainter(
          hourAngle: hourAngle,
          minuteAngle: minuteAngle,
          secondAngle: secondAngle,
          tasks: widget.tasks, // ✅ FIX
        ),
      ),
    );
  }
}
