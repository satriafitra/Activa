import 'package:active/pages/navbar.dart';
import 'package:active/components/sidebar.dart';
import 'package:flutter/material.dart';
import 'pages/habit_list_page.dart'; // pastikan ini sesuai path

void main() {
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
      home: HabitListPage(),
    );
  }
}
