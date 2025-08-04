import 'package:awesome_notifications/awesome_notifications.dart';

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
}
