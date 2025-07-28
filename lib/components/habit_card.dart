import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../services/database_helper.dart';
import '../pages/habit_detail_page.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final bool isTodaySelected;
  final DateTime selectedDate;
  final int quantityCompleted;
  final bool showLine;
  final VoidCallback onReload;
  final ValueChanged<bool> onConfettiCheck;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.isTodaySelected,
    required this.selectedDate,
    required this.quantityCompleted,
    required this.showLine,
    required this.onReload,
    required this.onConfettiCheck,
  });

  @override
  Widget build(BuildContext context) {
    final isInactiveDay = !isTodaySelected;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left circle + dash
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.white,
                border: Border.all(color: Colors.green, width: 4),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            if (showLine)
              LayoutBuilder(
                builder: (context, constraints) {
                  final dashHeight = 6.0;
                  final dashCount = (80 / (dashHeight * 2)).floor();

                  return Column(
                    children: List.generate(dashCount, (_) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Container(
                          width: 2,
                          height: dashHeight,
                          color: Colors.grey.shade300,
                        ),
                      );
                    }),
                  );
                },
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Right content
        Expanded(
          child: Slidable(
            key: ValueKey(habit.id),
            endActionPane: ActionPane(
              motion: isCompleted ? const BehindMotion() : const DrawerMotion(),
              children: isTodaySelected
                  ? isCompleted
                      ? [
                          SlidableAction(
                            onPressed: (_) async {
                              await DatabaseHelper.instance.unmarkHabitAsCompleted(
                                habit.id!,
                                DateFormat('yyyy-MM-dd').format(selectedDate),
                              );
                              onReload();
                            },
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            icon: Icons.undo,
                            label: 'Undo',
                          ),
                        ]
                      : [
                          SlidableAction(
                            onPressed: (_) async {
                              await DatabaseHelper.instance.markHabitAsCompleted(
                                habit.id!,
                                DateFormat('yyyy-MM-dd').format(selectedDate),
                              );
                              onConfettiCheck(true);
                              onReload();
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.check,
                            label: 'Selesai',
                          ),
                        ]
                  : [],
            ),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HabitDetailPage(habit: habit),
                  ),
                );
                if (result == true) onReload();
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: isInactiveDay
                      ? Colors.grey.shade200
                      : (isCompleted ? Colors.grey.shade200 : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isInactiveDay || isCompleted
                      ? []
                      : [
                          const BoxShadow(
                            color: Color.fromARGB(20, 0, 0, 0),
                            blurRadius: 19,
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    // Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isInactiveDay
                            ? Colors.grey.shade300
                            : (isCompleted
                                ? Colors.grey.shade400
                                : Color(int.parse(habit.color))
                                    .withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        IconData(int.parse(habit.icon),
                            fontFamily: 'MaterialIcons'),
                        color: isInactiveDay
                            ? Colors.grey
                            : (isCompleted
                                ? Colors.white
                                : Color(int.parse(habit.color))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 600),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isInactiveDay
                                  ? Colors.grey
                                  : (isCompleted ? Colors.grey : Colors.black),
                              decoration: isCompleted && !isInactiveDay
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            child: Text(habit.name),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${habit.progress}/${habit.quantity} ${habit.unit}",
                            style: GoogleFonts.poppins(
                              color: isInactiveDay
                                  ? Colors.grey
                                  : (isCompleted
                                      ? Colors.grey
                                      : Color(int.parse(habit.color))),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
