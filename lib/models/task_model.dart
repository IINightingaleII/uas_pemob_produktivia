class TaskModel {
  final String id;
  final String title;
  final String time; // Format: "HH:mm"
  final int color; // Color value as int (0xFF...)
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.time,
    required this.color,
    this.isCompleted = false,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? time,
    int? color,
    bool? isCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

