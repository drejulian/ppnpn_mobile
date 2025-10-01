import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );

    // Create notification channels
    await _createNotificationChannels();

    // Request notification permissions
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      print('DEBUG: 📱 Notification permissions granted: $granted');
      
      // Also request exact alarm permission for Android 12+
      await androidPlugin.requestExactAlarmsPermission();
      print('DEBUG: 📱 Exact alarms permission requested');
    }
  }

  // Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel taskChannel = AndroidNotificationChannel(
      'task_reminders',
      'Task Reminders',
      description: 'Notifications for task reminders',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel dueDateChannel = AndroidNotificationChannel(
      'due_date_reminders', 
      'Due Date Reminders',
      description: 'Notifications for due date reminders',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel mediaSosialChannel = AndroidNotificationChannel(
      'media_sosial_notifications',
      'Media Sosial Notifications',
      description: 'Notifications for media sosial activities',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 255, 0, 0),
    );

    const AndroidNotificationChannel absensiChannel = AndroidNotificationChannel(
      'absensi_notifications',
      'Absensi Notifications', 
      description: 'Notifications for attendance check-in and check-out',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 0, 255, 0),
    );

    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(taskChannel);
    await androidPlugin?.createNotificationChannel(dueDateChannel);
    await androidPlugin?.createNotificationChannel(mediaSosialChannel);
    await androidPlugin?.createNotificationChannel(absensiChannel);
    
    print('DEBUG: 📱 Created notification channels including media_sosial_notifications');
  }

  // Check if notification permissions are granted
  static Future<bool> hasNotificationPermissions() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.areNotificationsEnabled();
      print('DEBUG: 📱 Notifications enabled: $granted');
      return granted ?? false;
    }
    
    return true; // For iOS or other platforms
  }

  // Request notification permissions
  static Future<bool> requestPermissionsWithDialog(BuildContext context) async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      print('DEBUG: 📱 Permission request result: $granted');
      return granted ?? false;
    }
    
    return true; // For iOS or other platforms
  }

  // Test notification - untuk debugging
  static Future<void> showTestNotification() async {
    try {
      print('DEBUG: 📱 Sending test notification...');
      
      await showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Test Notification',
        body: 'Ini adalah test notifikasi untuk memastikan sistem berfungsi dengan baik.',
        payload: 'test_notification',
      );
      
      print('DEBUG: ✅ Test notification sent successfully');
    } catch (e) {
      print('DEBUG: ❌ Failed to send test notification: $e');
    }
  }

  // Show immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders', 
      channelDescription: 'Notifications for task reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show absensi notification
  static Future<void> showAbsensiNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'absensi_notifications',
      'Absensi Notifications',
      channelDescription: 'Notifications for attendance check-in and check-out',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 0, 255, 0),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Schedule task reminder notification
  static Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tz.TZDateTime scheduledDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
      
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'task_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('Scheduled reminder notification for: $scheduledDate');
    } catch (e) {
      print('Error scheduling task reminder: $e');
    }
  }

  // Schedule due date reminder notification
  static Future<void> scheduleDueDateReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tz.TZDateTime scheduledDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
      
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'due_date_reminders',
        'Due Date Reminders',
        channelDescription: 'Notifications for due date reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('Scheduled due date notification for: $scheduledDate');
    } catch (e) {
      print('Error scheduling due date reminder: $e');
    }
  }

  // Show task completion notification
  static Future<void> showTaskCompletionNotification({
    required String taskTitle,
  }) async {
    await showNotification(
      id: taskTitle.hashCode + 999, // Different ID to avoid conflicts
      title: 'Task Completed! ',
      body: 'Great job completing "$taskTitle"',
    );
  }

  // Show media sosial notification (generic)
  static Future<void> showMediaSosialNotification({
    required String platform,
    required String username,
    String? action = 'ditambahkan',
  }) async {
    try {
      await showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Media Sosial Berhasil ${action!.toUpperCase()}',
        body: 'Media sosial $platform dengan username @$username telah berhasil $action',
        payload: 'media_sosial_$platform',
      );
      
      print('DEBUG: 📱 Media sosial notification sent successfully');
    } catch (e) {
      print('DEBUG: ❌ Failed to send media sosial notification: $e');
    }
  }

  // Show media sosial added notification
  static Future<void> showMediaSosialAddedNotification({
    required String platform,
    required String username,
    int? followers,
    bool isVerified = false,
  }) async {
    try {
      final followersText = followers != null ? ' ($followers followers)' : '';
      final verifiedText = isVerified ? ' ✓' : '';
      
      await showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Media Sosial Berhasil Ditambahkan',
        body: 'Akun $platform ($username)$followersText$verifiedText telah berhasil ditambahkan ke media sosial Anda.',
        payload: 'medsos_added_${platform}_$username',
      );
      
      print('DEBUG: 📱 Media sosial added notification sent successfully');
    } catch (e) {
      print('DEBUG: ❌ Failed to send added notification: $e');
    }
  }

  // Show media sosial updated notification
  static Future<void> showMediaSosialUpdatedNotification({
    required String platform,
    required String username,
  }) async {
    try {
      await showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Media Sosial Berhasil Diperbarui',
        body: 'Akun $platform ($username) telah berhasil diperbarui.',
        payload: 'medsos_updated_${platform}_$username',
      );
      
      print('DEBUG: 📱 Media sosial updated notification sent successfully');
    } catch (e) {
      print('DEBUG: ❌ Failed to send updated notification: $e');
    }
  }

  // Show media sosial deleted notification
  static Future<void> showMediaSosialDeletedNotification({
    required String platform,
    required String username,
  }) async {
    try {
      await showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Media Sosial Berhasil Dihapus',
        body: 'Akun $platform ($username) telah berhasil dihapus dari media sosial Anda.',
        payload: 'medsos_deleted_${platform}_$username',
      );
      
      print('DEBUG: 📱 Media sosial deleted notification sent successfully');
    } catch (e) {
      print('DEBUG: ❌ Failed to send deleted notification: $e');
    }
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all notifications for a specific task
  static Future<void> cancelTaskNotifications(String taskTitle) async {
    await cancelNotification(taskTitle.hashCode);
    await cancelNotification(taskTitle.hashCode + 1);
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
