// lib/pages/list_category_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/icon_helper.dart';

import '../models/habit_category.dart';
import '../models/habit.dart';

class ListCategoryPage extends StatelessWidget {
  final HabitCategory category;

  const ListCategoryPage({super.key, required this.category});

  // Parse hex like "#B3E5FC" -> Color
  Color? _tryHexToColor(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      final buffer = StringBuffer();
      if (clean.length == 6) buffer.write('ff');
      buffer.write(clean);
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return null;
    }
  }

  String _subtitle(Habit h) {
    // contoh subtitle sederhana: "1 glass • Morning"
    final unit = (h.unit.isNotEmpty) ? h.unit : 'kali';
    final qty = h.quantity;
    final tod = (h.timeOfDay.isNotEmpty)
        ? '${h.timeOfDay[0].toUpperCase()}${h.timeOfDay.substring(1)}'
        : '-';
    return '$qty $unit • $tod';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category.title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: category.habits.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final habit = category.habits[index];
          final accent = _tryHexToColor(habit.color) ?? const Color(0xFFEFF1F5);

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: Colors.black.withOpacity(0.04)),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: buildIconFromString(habit.icon,),
                ),
              ),
              title: Text(
                habit.name,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              subtitle: Text(
                _subtitle(habit),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () {
                // NEXT: bisa diarahkan ke AddHabitPage untuk prefill dari rekomendasi
                // Navigator.push(context, MaterialPageRoute(
                //   builder: (_) => AddHabitPage(prefill: habit),
                // ));
              },
            ),
          );
        },
      ),
    );
  }
}
