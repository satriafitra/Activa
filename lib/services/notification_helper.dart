import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';


class NotificationHelper {
  // Panggil ini saat user menambahkan One-Time Task
  static Future<void> scheduleOneTimeTaskNotification({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    if (dateTime.isBefore(DateTime.now())) {
      print(
          '[❌ ERROR] Reminder "$title" tidak bisa diset di masa lalu: $dateTime');
      return;
    }
    final schedule = NotificationCalendar(
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
      hour: dateTime.hour,
      minute: dateTime.minute,
      second: dateTime.second,
      millisecond: 0,
      repeats: false,
    );

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'task_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        // ❌ customSound: 'success', => sudah tidak perlu
      ),
      schedule: schedule,
    );
  }

  // Panggil ini kalau task diedit dan kita ingin membatalkan notifikasi lama
  static Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  static Future<void> scheduleHabitNotification({
    required int id,
    required TimeOfDay reminderTime,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();

    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (scheduledTime.isBefore(now)) {
      print(
          '[❌ ERROR] Reminder habit "$title" tidak bisa diset di masa lalu: $scheduledTime');
      return;
    }

    final schedule = NotificationCalendar(
      year: scheduledTime.year,
      month: scheduledTime.month,
      day: scheduledTime.day,
      hour: scheduledTime.hour,
      minute: scheduledTime.minute,
      second: 0,
      millisecond: 0,
      repeats: false, // bisa kamu ubah ke true kalau mau daily habit reminder
    );

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id, // gunakan ID unik habit
        channelKey: 'task_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: schedule,
    );
  }
}
