import 'package:active/models/habit.dart';


class HabitWithStatus {
  final Habit habit;
  final bool isCompleted;

  HabitWithStatus({required this.habit, required this.isCompleted});
}
