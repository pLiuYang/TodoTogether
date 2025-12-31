import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/services.dart';

import '../models/task.dart';
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    // Request exact alarms permission (Android 14+ may redirect to settings)
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> scheduleNotification(Task task) async {
    if (task.reminderTime == null || task.status == TaskStatus.done) {
      await cancelNotification(task.id);
      return;
    }

    if (task.reminderTime!.isBefore(DateTime.now())) {
      return;
    }

    // Generate a unique ID for the notification based on the task ID string
    final int notificationId = task.id.hashCode;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final canExact = await androidPlugin?.canScheduleExactNotifications() ?? false;
    final mode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await _notifications.zonedSchedule(
        notificationId,
        'Task Reminder',
        task.title,
        tz.TZDateTime.from(task.reminderTime!, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (e) {
      // Fallback to inexact scheduling if exact alarms are not permitted
      if (e.code == 'exact_alarm_not_permitted') {
        await _notifications.zonedSchedule(
          notificationId,
          'Task Reminder',
          task.title,
          tz.TZDateTime.from(task.reminderTime!, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'task_reminders',
              'Task Reminders',
              channelDescription: 'Notifications for task reminders',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> cancelNotification(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
