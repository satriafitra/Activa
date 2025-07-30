import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationHelper {
  /// Jadwalkan notifikasi (mirip dengan zonedSchedule sebelumnya)
  static Future<void> scheduleNotification({
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
        repeats: false,
      ),
    );
  }

  /// Batalkan notifikasi berdasarkan ID
  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}
