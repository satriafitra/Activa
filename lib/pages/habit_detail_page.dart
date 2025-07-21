import 'package:active/models/habit.dart';
import 'package:flutter/material.dart';

class HabitDetailPage extends StatelessWidget {
  final Habit habit;

  const HabitDetailPage({super.key, required this.habit});

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse('FF${hexColor.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _parseColor(habit.color);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(habit.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: Color(int.parse(habit.color)).withOpacity(0.2),
                child: Icon(
                  IconData(int.parse(habit.icon), fontFamily: 'MaterialIcons'),
                  color: Color(int.parse(habit.color)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailTile('Nama Habit', habit.name),
            _buildDetailTile('Waktu Dilakukan', habit.timeOfDay),
            _buildDetailTile('Hari Jadwal', '${habit.days}'),
            _buildDetailTile('Streak', '${habit.streak} hari berturut-turut'),
            _buildDetailTile('Medal', habit.medal),
            _buildDetailTile('Target', '${habit.quantity} ${habit.unit}'),
            _buildDetailTile('Remind', '${habit.reminderTime}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 5,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
