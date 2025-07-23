import 'package:active/services/database_helper.dart';
import 'package:active/models/habit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:active/pages/add_habit_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitDetailPage extends StatefulWidget {
  final Habit habit;

  const HabitDetailPage({super.key, required this.habit});

  @override
  _HabitDetailPageState createState() => _HabitDetailPageState();
}

class _HabitDetailPageState extends State<HabitDetailPage> {
  List<Habit> _habits = [];
  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _refreshHabitDetail() async {
    if (widget.habit.id != null) {
      final refreshedHabit =
          await DatabaseHelper.instance.getHabitById(widget.habit.id!);
      if (refreshedHabit != null) {
        setState(() {
          widget.habit.name = refreshedHabit.name;
          widget.habit.color = refreshedHabit.color;
          widget.habit.icon = refreshedHabit.icon;
          widget.habit.progress = refreshedHabit.progress;
          widget.habit.quantity = refreshedHabit.quantity;
          widget.habit.unit = refreshedHabit.unit;
          widget.habit.reminderTime = refreshedHabit.reminderTime;
          widget.habit.streak = refreshedHabit.streak;
        });
      }
    }
  }

  Future<void> _loadHabits() async {
    final habits = await DatabaseHelper.instance.getHabits();
    setState(() {
      _habits = habits;
    });
  }

  Future<void> _deleteHabit(int id) async {
    await DatabaseHelper.instance.deleteHabit(id);
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse('FF${hexColor.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final Color color = _parseColor(habit.color);
    final time = habit.reminderTime ?? '-';
    final int doneCount = 0; // TODO: Ganti jika ada data progress harian
    final int total = habit.quantity == 0 ? 1 : habit.quantity;
    final double progress = doneCount / total;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddHabitPage(habit: habit),
                ),
              );
              await _refreshHabitDetail();
            },
            icon: const Icon(
              Icons.edit,
              color: Color.fromARGB(255, 107, 151, 255),
            ),
          ),
          IconButton(
            onPressed: () async {
              await _deleteHabit(habit.id!);
              Navigator.pop(
                  context, true); // kirim sinyal kalau sudah ada perubahan
            },
            icon: const Icon(
              Icons.delete,
              color: Color.fromARGB(255, 255, 103, 103),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row Icon + Title
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      Color(int.parse(habit.color)).withOpacity(0.2),
                  child: Icon(
                    IconData(int.parse(habit.icon),
                        fontFamily: 'MaterialIcons'),
                    color: Color(int.parse(habit.color)),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "${habit.progress}/${habit.quantity} ${habit.unit}",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (habit.progress / habit.quantity).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                color: Color(int.parse(habit.color)),
              ),
            ),

            const SizedBox(height: 20),

            // Repeat & Reminder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoColumn("Repeat", "Daily"),
                _infoColumn("Remind", time),
              ],
            ),

            const SizedBox(height: 20),

            // Kalender
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 19,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay:
                    DateTime(DateTime.now().year, DateTime.now().month, 1),
                lastDay:
                    DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
                focusedDay: DateTime.now(),
                calendarFormat: CalendarFormat.month,
                availableGestures: AvailableGestures.none,
                pageJumpingEnabled: false,
                locale: 'id_ID',
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: const TextStyle(color: Colors.black),
                  weekendTextStyle: TextStyle(color: Colors.grey[700]),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.grey[800]),
                  weekendStyle: TextStyle(color: Colors.grey[600]),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronVisible: false,
                  rightChevronVisible: false,
                  titleTextStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Streak Card with Image Background
            Container(
              height: 140,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/sidebar_banner.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${habit.streak} days",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Your current streak",
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.yellow),
                      Text(
                        "0 days",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Your longest streak",
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black)),
      ],
    );
  }
}
