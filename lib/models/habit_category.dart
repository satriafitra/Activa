import 'habit.dart'; // impor model Habit yang udah kamu buat

class HabitCategory {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Habit> habits;

  HabitCategory({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.habits,
  });
}
