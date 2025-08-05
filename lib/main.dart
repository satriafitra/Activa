import 'package:active/components/sidebar.dart';
import 'package:active/pages/add_habit/one_time_task_page.dart';
import 'package:active/pages/chat_page.dart';
import 'package:active/pages/starter_page.dart';
import 'package:active/testing/notification_test.dart';
import 'package:active/testing/sound_test.dart';
import 'package:active/pages/streak.dart';
import 'package:flutter/material.dart';
import 'pages/habit_list/habit_list_page.dart'; // pastikan ini sesuai path
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await dotenv.load();

  print('[ENV] Loaded key: ${dotenv.env['GEMINI_API_KEY']}');

  // Inisialisasi notifikasi
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'task_channel',
        channelName: 'Task Reminder',
        channelDescription: 'Reminder for your task',
        defaultColor: Colors.orange,
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
        soundSource: 'resource://raw/notif',
      ),
    ],
    debug: true,
  );

  // Minta izin
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // 🔥 Cek apakah user sudah pernah buka app
  final prefs = await SharedPreferences.getInstance();
  final seenStarter = prefs.getBool('seen_starter') ?? false;

  runApp(MyApp(seenStarterPage: seenStarter));
}

class MyApp extends StatelessWidget {
  final bool seenStarterPage;

  const MyApp({super.key, required this.seenStarterPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pactiva',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.greenAccent,
          secondary: Colors.green,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      // ⬇️ arahkan ke StarterPage jika belum pernah buka
      home: seenStarterPage ? HabitListPage() : const StarterPage(),
    );
  }
}

