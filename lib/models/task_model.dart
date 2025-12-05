import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String time; // Format: "HH:mm"
  final int color; // Color value as int (0xFF...)
  final bool isCompleted;
  final DateTime? date; // Date for the task
  final String? alarmTime; // Alarm time in format "HH:mm"
  final String? duration; // Duration in format "H:mm"
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.time,
    required this.color,
    this.isCompleted = false,
    this.date,
    this.alarmTime,
    this.duration,
    this.createdAt,
    this.updatedAt,
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'time': time,
      'color': color,
      'is_completed': isCompleted,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'alarm_time': alarmTime,
      'duration': duration,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory TaskModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TaskModel(
      id: id,
      title: data['title'] ?? '',
      time: data['time'] ?? '',
      color: data['color'] ?? 0xFFFF9800,
      isCompleted: data['is_completed'] ?? false,
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null,
      alarmTime: data['alarm_time'],
      duration: data['duration'],
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
      updatedAt: data['updated_at'] != null ? (data['updated_at'] as Timestamp).toDate() : null,
    );
  }
}

