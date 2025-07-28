// habit_logic.dart
import 'package:intl/intl.dart';
import 'package:active/services/database_helper.dart';
import 'package:active/models/habit.dart';
import 'package:active/models/HabitWithStatus.dart';

Future<List<HabitWithStatus>> loadHabitsForDate({
  required DateTime date,
  required DatabaseHelper dbHelper,
}) async {
  final allHabits = await dbHelper.getHabits();
  final selectedDay = DateFormat('EEEE', 'id_ID').format(date);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final selectedOnlyDate = DateTime(date.year, date.month, date.day);

  final filtered = <Habit>[];

  for (final habit in allHabits) {
    final days = habit.days.split(',').map((e) => e.trim()).toList();

    if (selectedOnlyDate.isBefore(today)) {
      final hasLog = await dbHelper.isHabitExistInLogOnDate(
        habit.id!,
        DateFormat('yyyy-MM-dd').format(date),
      );
      if (hasLog) filtered.add(habit);
    } else {
      if (days.contains(selectedDay)) filtered.add(habit);
    }
  }

  final habitStatuses = await Future.wait(filtered.map((habit) async {
    final isCompleted =
        await dbHelper.isHabitCompletedOnDate(habit.id!, date);
    final quantityDone = await dbHelper.getQuantityCompletedOnDate(
      habit.id!,
      DateFormat('yyyy-MM-dd').format(date),
    );

    habit.progress = quantityDone;

    return HabitWithStatus(
      habit: habit,
      isCompleted: isCompleted,
      quantityCompleted: quantityDone,
    );
  }));

  return habitStatuses;
}
