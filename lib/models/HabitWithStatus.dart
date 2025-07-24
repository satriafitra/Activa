import 'package:active/models/habit.dart';

class HabitWithStatus {
  final Habit habit;
  final bool isCompleted;
  final int quantityCompleted;

  HabitWithStatus(
      {required this.habit,
      required this.isCompleted,
      required this.quantityCompleted});
}
