import 'package:active/components/sidebar.dart';
import 'package:active/pages/chat_page.dart';
import 'package:active/pages/sound_test.dart';
import 'package:flutter/material.dart';
import 'pages/habit_list/habit_list_page.dart'; // pastikan ini sesuai path
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await dotenv.load(); // INI PENTING
  print('[ENV] Loaded key: ${dotenv.env['GEMINI_API_KEY']}');

  runApp(MyApp());
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
      home: HabitListPage(),
    );
  }
}
