class TaskModel {
  final String id;
  final String title;
  final String time; // Format: "HH:mm"
  final int color; // Color value as int (0xFF...)
  final bool isCompleted;
  final DateTime? date; // Date for the task
  final String? alarmTime; // Alarm time in format "HH:mm"
  final String? duration; // Duration in format "H:mm"

  TaskModel({
    required this.id,
    required this.title,
    required this.time,
    required this.color,
    this.isCompleted = false,
    this.date,
    this.alarmTime,
    this.duration,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? time,
    int? color,
    bool? isCompleted,
    DateTime? date,
    String? alarmTime,
    String? duration,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      alarmTime: alarmTime ?? this.alarmTime,
      duration: duration ?? this.duration,
    );
  }
}

