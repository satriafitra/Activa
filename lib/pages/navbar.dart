import 'package:active/pages/habit_list_page.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AnimatedNavBar extends StatefulWidget {
  @override
  _AnimatedNavBarState createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar> {
  int _selectedIndex = 0; // Menyimpan indeks tab yang dipilih
  PageController _pageController =
      PageController(); // Kontroler untuk mengelola perpindahan halaman

  // Fungsi untuk menangani tab yang dipilih
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index; // Update indeks tab saat halaman berubah
          });
        },
        children: [
          HabitListPage(), // Halaman 0: JadwalPage
          Text('Hello'), // Halaman 1: SuratPage
          Text('Hai'),
          Text('Wassup')
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(24, 0, 0, 0),
              blurRadius: 19,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            bool isSelected =
                _selectedIndex == index; // Mengecek apakah tab ini dipilih
            List<List<IconData>> icons = [
              [Iconsax.home, Iconsax.home_15], // outline, filled
              [Iconsax.book, Iconsax.book],
              [Iconsax.calendar, Iconsax.calendar_15],
              [Iconsax.information, Iconsax.information5],
            ];

            List<String> labels = ["Home", "Surah", "Jadwal", "About"];
            return GestureDetector(
              onTap: () => _onItemTapped(index), // Memilih tab saat ditekan
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green.withOpacity(0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icons[index][isSelected ? 1 : 0],
                  color: isSelected ? Color(0xff01A65A) : Colors.grey,
                  size: isSelected ? 30 : 24,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
