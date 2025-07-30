import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotifTestPage extends StatefulWidget {
  const NotifTestPage({super.key});

  @override
  State<NotifTestPage> createState() => _NotifTestPageState();
}

class _NotifTestPageState extends State<NotifTestPage> {
  @override
  void initState() {
    super.initState();

    // Minta permission notifikasi jika belum
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void _scheduleNotif() {
    final now = DateTime.now();
    final schedule = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second + 5);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'task_channel',
        title: 'Notifikasi Test 🎉',
        body: 'Notifikasi ini muncul setelah 5 detik!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: schedule.year,
        month: schedule.month,
        day: schedule.day,
        hour: schedule.hour,
        minute: schedule.minute,
        second: schedule.second,
        millisecond: 0,
        repeats: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tes Notifikasi')),
      body: Center(
        child: ElevatedButton(
          onPressed: _scheduleNotif,
          child: const Text('Tes Notif (5 detik)'),
        ),
      ),
    );
  }
}
