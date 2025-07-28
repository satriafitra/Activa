import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ConfettiOverlay extends StatelessWidget {
  final bool isVisible;
  final Duration animationDuration;

  const ConfettiOverlay({
    super.key,
    required this.isVisible,
    required this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        duration: animationDuration,
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSlide(
                duration: animationDuration,
                offset: isVisible ? Offset.zero : const Offset(0, 0),
                child: Transform.translate(
                  offset: const Offset(-115, 0),
                  child: Lottie.asset(
                    'assets/animations/confetti.json',
                    repeat: false,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: AnimatedSlide(
                  duration: animationDuration,
                  offset: isVisible ? Offset.zero : const Offset(0, 0.2),
                  child: AnimatedOpacity(
                    duration: animationDuration,
                    opacity: isVisible ? 1.0 : 0.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Great Job!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(2, 3),
                                blurRadius: 6,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "You're completed all\ntasks today!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
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
      ),
    );
  }
}
