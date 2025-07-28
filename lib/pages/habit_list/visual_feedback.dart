import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

void showStreakOverlay(BuildContext context) {
  final player = AudioPlayer();
  player.play(AssetSource('sounds/streak.wav'));

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Streak Overlay',
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation =
          CurvedAnimation(parent: animation, curve: Curves.elasticOut);

      return ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
        child: FadeTransition(
          opacity: animation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 280,
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 0, bottom: 42),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 123, 199),
                  borderRadius: BorderRadius.circular(38),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(
                      'assets/animations/medal.json',
                      width: 150,
                      height: 150,
                      repeat: true,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '1 Day Streak!',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep going your\ngreat job!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(211, 255, 255, 255),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      '24 Days more to Silver!',
                      style: GoogleFonts.poppins(
                        color: Colors.amberAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: 0.3,
                          minHeight: 10,
                          backgroundColor: Colors.white24,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  // ⏳ Auto close setelah 4 detik
  Future.delayed(const Duration(seconds: 4), () {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  });
}
