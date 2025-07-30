import 'package:active/components/sidebar.dart';
import 'package:active/pages/add_habit/one_time_task_page.dart';
import 'package:active/pages/chat_page.dart';
import 'package:active/testing/notification_test.dart';
import 'package:active/testing/sound_test.dart';
import 'package:active/pages/streak.dart';
import 'package:flutter/material.dart';
import 'pages/habit_list/habit_list_page.dart'; // pastikan ini sesuai path
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await dotenv.load(); // INI PENTING
  print('[ENV] Loaded key: ${dotenv.env['GEMINI_API_KEY']}');

  // ✅ Inisialisasi Awesome Notifications
  await AwesomeNotifications().initialize(
    null, // gunakan default icon dari launcher
    [
      NotificationChannel(
        channelKey: 'task_channel',
        channelName: 'Task Notifications',
        channelDescription: 'Pengingat untuk task dan habit kamu',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
    debug: true,
  );

  // ✅ Minta izin notifikasi
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.greenAccent,
          secondary: Colors.green,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      home: NotifTestPage(),
    );
  }
}
