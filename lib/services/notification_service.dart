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

    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      // Create notification channel (required for Android 8.0+)
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'task_notifications', // id - MUST match the one used in notification details
        'Task Notifications', // name
        description: 'Notifications for task reminders',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await androidImplementation.createNotificationChannel(channel);
      print('✅ Notification channel created: ${channel.id}');

      // Request notification permission (Android 13+)
      final notificationPermission = await androidImplementation.requestNotificationsPermission();
      print('📱 Notification permission: $notificationPermission');

      // Request exact alarm permission (Android 12+)
      // This is CRITICAL for scheduled notifications to work when app is closed
      final exactAlarmPermission = await androidImplementation.requestExactAlarmsPermission();
      print('⏰ Exact alarm permission: $exactAlarmPermission');
      
      if (exactAlarmPermission == false) {
        print('⚠️ WARNING: Exact alarm permission denied! Scheduled notifications may not work.');
      }
    }

    _initialized = true;
    print('🎉 Notification service initialized successfully');
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
      print('⚠️ Skipping notification - Task completed: ${task.isCompleted}, Date: ${task.date}');
      return;
    }

    // CHECK: Can we schedule exact alarms?
    final canSchedule = await canScheduleExactAlarms();
    if (!canSchedule) {
      print('❌ Cannot schedule notification - Exact alarm permission not granted!');
      print('   📱 Go to: Settings > Apps > Produktivia > Alarms & reminders > ALLOW');
      return;
    }

    // Parse alarm time or use task time
    final notificationTime = _parseNotificationTime(task);
    if (notificationTime == null) {
      print('⚠️ Skipping notification - Invalid notification time for task: ${task.title}');
      return;
    }

    print('📅 Scheduling notification for: ${task.title}');
    print('   Time: $notificationTime');
    print('   Now: ${tz.TZDateTime.now(tz.local)}');

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
    
    try {
      // Schedule notification - REMOVED matchDateTimeComponents to make it one-time only
      await _notifications.zonedSchedule(
        notificationId,
        task.title,
        'Task scheduled at ${task.time}',
        notificationTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      
      print('✅ Notification scheduled successfully - ID: $notificationId');
    } catch (e) {
      print('❌ Failed to schedule notification: $e');
      rethrow;
    }
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

  // Check if app can schedule exact alarms
  Future<bool> canScheduleExactAlarms() async {
    if (!_initialized) {
      await initialize();
    }

    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      try {
        // On Android 12+ (API 31+), check if permission is granted
        final canSchedule = await androidImplementation.canScheduleExactNotifications();
        print('🔍 Can schedule exact alarms: $canSchedule');
        
        if (!canSchedule!) {
          print('⚠️ CANNOT schedule exact alarms!');
          print('   Please go to: Settings > Apps > Produktivia > Alarms & reminders > Allow');
        }
        
        return canSchedule;
      } catch (e) {
        print('⚠️ Error checking exact alarm permission: $e');
        return false;
      }
    }
    
    return true; // Assume OK for non-Android
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
    if (task.date == null) {
      print('⚠️ Task ${task.title}: date is null');
      return null;
    }

    // Use alarmTime if available, otherwise use task time
    final timeString = task.alarmTime ?? task.time;
    print('🔔 Parsing time for ${task.title}: $timeString (alarm: ${task.alarmTime}, task: ${task.time})');
    
    final timeParts = timeString.split(':');
    
    if (timeParts.length != 2) {
      print('❌ Invalid time format: $timeString');
      return null;
    }

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

      print('📅 Notification date: $notificationDate');

      // Convert to timezone-aware datetime
      final tzDateTime = tz.TZDateTime.from(notificationDate, tz.local);
      final now = tz.TZDateTime.now(tz.local);
      
      print('   TZ DateTime: $tzDateTime');
      print('   Current time: $now');
      print('   Is in future: ${tzDateTime.isAfter(now)}');
      
      // Don't schedule notification if time is in the past
      if (tzDateTime.isBefore(now)) {
        print('⚠️ Notification time is in the past, skipping');
        return null;
      }
      
      return tzDateTime;
    } catch (e) {
      print('❌ Error parsing notification time: $e');
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

