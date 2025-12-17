import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // Set timezone sesuai kebutuhan
    } catch (e) {
      // Fallback to UTC if timezone not found
      tz.setLocalLocation(tz.UTC);
    }

    // Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    if (_notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>() != null) {
      await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
          .requestNotificationsPermission();
    }

    _initialized = true;
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
    // You can navigate to specific screen based on payload
  }

  // Schedule notification for a task
  Future<void> scheduleTaskNotification(TaskModel task) async {
    if (!_initialized) {
      await initialize();
    }

    // Don't schedule notification if task is completed or has no date/time
    if (task.isCompleted || task.date == null) {
      return;
    }

    // Parse alarm time or use task time
    final notificationTime = _parseNotificationTime(task);
    if (notificationTime == null) {
      return;
    }

    // Create notification details
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_notifications',
      'Task Notifications',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Generate unique notification ID from task ID
    // Use hash code to ensure it's a valid int
    final notificationId = task.id.hashCode.abs();
    
    // Schedule notification
    await _notifications.zonedSchedule(
      notificationId,
      task.title,
      'Task scheduled at ${task.time}',
      notificationTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel notification for a task
  Future<void> cancelTaskNotification(String taskId) async {
    if (!_initialized) {
      await initialize();
    }

    // Use hash code to match notification ID
    final notificationId = taskId.hashCode.abs();
    await _notifications.cancel(notificationId);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) {
      await initialize();
    }

    await _notifications.cancelAll();
  }

  // Update notification when task is updated
  Future<void> updateTaskNotification(TaskModel task) async {
    // Cancel old notification
    await cancelTaskNotification(task.id);
    
    // Schedule new notification if task is not completed
    if (!task.isCompleted) {
      await scheduleTaskNotification(task);
    }
  }

  // Parse notification time from task
  tz.TZDateTime? _parseNotificationTime(TaskModel task) {
    if (task.date == null) return null;

    // Use alarmTime if available, otherwise use task time
    final timeString = task.alarmTime ?? task.time;
    final timeParts = timeString.split(':');
    
    if (timeParts.length != 2) return null;

    try {
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Combine date and time
      final notificationDate = DateTime(
        task.date!.year,
        task.date!.month,
        task.date!.day,
        hour,
        minute,
      );

      // Convert to timezone-aware datetime
      final tzDateTime = tz.TZDateTime.from(notificationDate, tz.local);
      
      // Don't schedule notification if time is in the past
      if (tzDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
        return null;
      }
      
      return tzDateTime;
    } catch (e) {
      return null;
    }
  }

  // Schedule notifications for all active tasks
  Future<void> scheduleAllTaskNotifications(List<TaskModel> tasks) async {
    if (!_initialized) {
      await initialize();
    }

    // Cancel all existing notifications first
    await cancelAllNotifications();

    // Schedule notifications for all active (non-completed) tasks
    for (final task in tasks) {
      if (!task.isCompleted && task.date != null) {
        await scheduleTaskNotification(task);
      }
    }
  }
}

