import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:active/pages/habit_list/habit_list_page.dart';

class StarterPage extends StatefulWidget {
  const StarterPage({super.key});

  @override
  State<StarterPage> createState() => _StarterPageState();
}

class _StarterPageState extends State<StarterPage> with TickerProviderStateMixin {
  late AnimationController _slideInController;
  late Animation<Offset> _slideInAnimation;

  @override
  void initState() {
    super.initState();

    _slideInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideInAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // dari bawah
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideInController,
      curve: Curves.easeOutCubic,
    ));

    _slideInController.forward();
  }

  @override
  void dispose() {
    _slideInController.dispose();
    super.dispose();
  }

  Future<void> _onStartPressed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenStarterPage', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HabitListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Step 1: Starter background
          Positioned.fill(
            child: Image.asset(
              'assets/images/starter_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Step 2: Foreground + text + button slide in
          SlideTransition(
            position: _slideInAnimation,
            child: Stack(
              children: [
                // Character foreground
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/starter_character_full.png',
                    fit: BoxFit.cover,
                  ),
                ),

                // Text + Button di bagian bawah layar
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'The best time to start is now!',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _onStartPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'LETS DO IT',
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
