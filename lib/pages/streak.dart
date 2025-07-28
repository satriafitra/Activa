import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../models/habit.dart'; // ganti sesuai path model kamu
import '../services/database_helper.dart'; // ganti sesuai path database kamu

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int currentStreak = 0;
  int longestStreak = 0;
  String nextMedal = "bronze";
  int neededStreak = 7;

  @override
  void initState() {
    super.initState();
    _loadOverallStats();
  }

  Future<void> _loadOverallStats() async {
    final db = await DatabaseHelper.instance;
    final habits = await db.getAllHabits();

    int totalCurrentStreak = 0;
    int totalLongestStreak = 0;

    for (var habit in habits) {
      totalCurrentStreak += (habit.currentStreak ?? 0).toInt();
      totalLongestStreak += (habit.longestStreak ?? 0).toInt();
    }

    // Logika penentuan medal dan needed streak
    String next = 'bronze';
    int needed = 0;

    if (totalCurrentStreak < 7) {
      next = 'bronze';
      needed = 7 - totalCurrentStreak;
    } else if (totalCurrentStreak < 14) {
      next = 'silver';
      needed = 14 - totalCurrentStreak;
    } else if (totalCurrentStreak < 30) {
      next = 'gold';
      needed = 30 - totalCurrentStreak;
    } else {
      next = 'platinum';
      needed = 50 - totalCurrentStreak;
    }

    setState(() {
      currentStreak = totalCurrentStreak;
      longestStreak = totalLongestStreak;
      neededStreak = needed.clamp(0, 999);
      nextMedal = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = currentStreak / (currentStreak + neededStreak);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.black),
        title: Text(
          'Your stats',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card: Current Streak
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/sidebar_banner.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your current streak',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$currentStreak Days',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Keep it up!',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Medal Progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ikon medal
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC701D), // bronze background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.medal_star,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Progress
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Streak $neededStreak days to reach $nextMedal',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  minHeight: 10,
                                  backgroundColor: const Color(0xFFE0E0E0),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.green),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
