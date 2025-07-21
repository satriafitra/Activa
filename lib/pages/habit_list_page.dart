import 'package:active/pages/habit_detail_page.dart';
import 'package:active/components/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:active/db/database_helper.dart';
import 'package:active/models/habit.dart';
import 'package:active/pages/add_habit_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitListPage extends StatefulWidget {
  @override
  _HabitListPageState createState() => _HabitListPageState();
}

class _HabitListPageState extends State<HabitListPage> {
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await DatabaseHelper.instance.getHabits();
    setState(() {
      _habits = habits;
    });
  }

  bool _isSidebarOpen = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _deleteHabit(int id) async {
    await DatabaseHelper.instance.deleteHabit(id);
    _loadHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(children: [
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleSidebar, // Fungsi untuk menampilkan sidebar
                      child: Icon(Icons.menu,
                          color: const Color.fromARGB(255, 0, 0, 0)),
                    ),
                    const SizedBox(width: 12),
                    Text("Today",
                        style: GoogleFonts.poppins(
                            fontSize: 22, fontWeight: FontWeight.w600)),
                    Spacer(),
                    Icon(Icons.emoji_events_outlined, color: Colors.brown),
                    const SizedBox(width: 12),
                    Container(
                      width: 70,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[300],
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.arrow_forward_ios, size: 12),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hardcoded Calendar Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: ['M', 'S', 'S', 'R', 'K', 'J', 'S']
                      .map((day) => Text(day, style: GoogleFonts.poppins()))
                      .toList(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final isSelected = i == 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0), // Atur jarak antar item di sini
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.green : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (i + 1).toString().padLeft(2, '0'),
                              style: GoogleFonts.poppins(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              // Image banner
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/banner.png'), // Sesuaikan dengan path kamu
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      // Teks di kiri bawah
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Keep it up!",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Teks di kanan bawah
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "TASK COMPLETE",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "1/4",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_habits
                        .any((h) => h.timeOfDay.toLowerCase() == 'pagi')) ...[
                      Text(
                        "MORNING",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color.fromARGB(132, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._habits
                          .where((habit) =>
                              habit.timeOfDay.toLowerCase() == 'pagi')
                          .map((habit) => _buildHabitCard(habit))
                          .toList(),
                      const SizedBox(height: 24),
                    ],
                    if (_habits
                        .any((h) => h.timeOfDay.toLowerCase() == 'siang')) ...[
                      Text(
                        "AFTERNOON",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color.fromARGB(132, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._habits
                          .where((habit) =>
                              habit.timeOfDay.toLowerCase() == 'siang')
                          .map((habit) => _buildHabitCard(habit))
                          .toList(),
                      const SizedBox(height: 24),
                    ],
                    if (_habits
                        .any((h) => h.timeOfDay.toLowerCase() == 'malam')) ...[
                      Text(
                        "EVENING",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color.fromARGB(132, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._habits
                          .where((habit) =>
                              habit.timeOfDay.toLowerCase() == 'malam')
                          .map((habit) => _buildHabitCard(habit))
                          .toList(),
                    ],
                  ],
                ),
              )
            ],
          ),
        ),

        /// ⬇️ Ini Sidebar reusable yang kamu buat
        SidebarOverlay(
          isOpen: _isSidebarOpen,
          onClose: _toggleSidebar,
          selectedItem: 'Today',
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddHabitPage()),
          );
          _loadHabits();
        },
        backgroundColor: const Color.fromARGB(
            255, 0, 97, 52), // Ganti warna sesuai keinginan
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), // Rounded
        ),
        child: Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress circle di kiriz
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
            ),
            if (habit.name != "Read book")
              Container(
                width: 2,
                height: 50,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Slidable(
            key: ValueKey(habit.id),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddHabitPage(habit: habit),
                      ),
                    );
                    _loadHabits();
                  },
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.edit,
                  borderRadius: BorderRadius.circular(12),
                  flex: 1,
                  spacing: 1,
                ),
                SlidableAction(
                  onPressed: (_) => _deleteHabit(habit.id!),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white, // warna icon + text
                  icon: Icons.delete,
                  borderRadius: BorderRadius.circular(12),
                )
              ],
            ),
            child: InkWell(
              // GANTI DARI GestureDetector KE INKWELL DI SINI
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HabitDetailPage(habit: habit),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16), // biar ripple-nya rapi
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(20, 0, 0, 0),
                      blurRadius: 19,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(int.parse(habit.color)).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        IconData(int.parse(habit.icon),
                            fontFamily: 'MaterialIcons'),
                        color: Color(int.parse(habit.color)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(habit.name,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            "${habit.quantity} ${habit.unit}",
                            style: GoogleFonts.poppins(
                                color: Color(int.parse(habit.color)),
                                fontWeight: FontWeight.w500,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
