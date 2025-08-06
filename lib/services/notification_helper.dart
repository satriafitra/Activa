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

  static Future<void> scheduleHabitReminderNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay reminderTime,
    required List<int> repeatDays, // Contoh: [1, 3, 5] untuk Senin, Rabu, Jumat
  }) async {
    for (int weekday in repeatDays) {
      final schedule = NotificationCalendar(
        weekday: weekday, // 1 = Monday, 7 = Sunday
        hour: reminderTime.hour,
        minute: reminderTime.minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      );

      // Gunakan ID unik per hari
      final notifId = id * 10 + weekday;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notifId,
          channelKey: 'task_channel',
          title: title,
          body: body,
          notificationLayout: NotificationLayout.Default,
          icon: 'resource://drawable/ic_stat_activa',
        ),
        schedule: schedule,
      );
    }
  }

  // ✅ Fungsi untuk membatalkan semua notifikasi berdasarkan id dan hari
  static Future<void> cancelHabitReminder(int baseId, List<int> days) async {
    for (int weekday in days) {
      final notifId = baseId * 10 + weekday;
      await AwesomeNotifications().cancel(notifId);
    }
  }
}
