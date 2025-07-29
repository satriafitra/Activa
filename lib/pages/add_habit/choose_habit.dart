import 'package:active/pages/add_habit/one_time_task_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:active/pages/add_habit/add_habit_page.dart';

class ChooseHabitTypePage extends StatelessWidget {
  const ChooseHabitTypePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 4),
            Text(
              'Create new habit',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // One-time task
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OneTimeTaskPage()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available, color: Colors.orange),
                    const SizedBox(width: 16),
                    Text(
                      "One-time tasks",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddHabitPage()),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.blue),
                    const SizedBox(width: 16),
                    Text(
                      "Regular habit",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              "OR CHOOSE FROM CATEGORIES",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            // Kategori 1
            _buildCategoryCard(
              context,
              title: "Trending habits",
              subtitle: "Take a step in the\nright directions.",
              imagePath: "assets/images/trending1.png",
            ),
            SizedBox(height: 12,),
            _buildCategoryCard(
              context,
              title: "Stay at home",
              subtitle: "Take a step in the\nright directions.",
              imagePath: "assets/images/stay.png",
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context,
      {required String title,
      required String subtitle,
      required String imagePath}) {
    return Container(
      width: double.infinity,
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
