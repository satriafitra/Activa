import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationHelper {
  // Panggil ini saat user menambahkan One-Time Task
  static Future<void> scheduleOneTimeTaskNotification({
    required int id,
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'task_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: dateTime.year,
        month: dateTime.month,
        day: dateTime.day,
        hour: dateTime.hour,
        minute: dateTime.minute,
        second: 0,
        millisecond: 0,
        preciseAlarm: true,
      ),
    );
  }

  // Panggil ini kalau task diedit dan kita ingin membatalkan notifikasi lama
  static Future<void> cancel(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
