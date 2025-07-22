import 'package:active/pages/habit_detail_page.dart';
import 'package:active/components/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:active/db/database_helper.dart';
import 'package:active/models/habit.dart';
import 'package:active/pages/add_habit_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';

class HabitListPage extends StatefulWidget {
  @override
  _HabitListPageState createState() => _HabitListPageState();
}

class _HabitListPageState extends State<HabitListPage> {
  List<Habit> _habits = [];

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isConfettiActive = false; // Untuk munculin widget
  bool _isConfettiVisible = false; // Untuk mengatur opacity/slide

  final Duration _animationDuration = Duration(milliseconds: 500);

  // ✅ Letakkan di sini
  bool _allHabitsCompleted(List<Habit> habits) {
    return habits.every((habit) => habit.progress >= habit.quantity);
  }

  // tampilkan overlay confetti
  bool _showConfetti = false;

  void _checkAllHabitsCompleted() {
    if (_allHabitsCompleted(_habits) && !_isConfettiActive) {
      setState(() {
        _isConfettiActive = true;
      });

      _audioPlayer.play(AssetSource('sounds/success.wav'));


      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isConfettiVisible = true;
          });
        }
      });

      // Delay untuk menutup animasi
      Future.delayed(Duration(seconds: 4), () {
        if (mounted) {
          setState(() {
            _isConfettiVisible = false;
          });

          // Hapus dari tree setelah animasi fade-out selesai
          Future.delayed(_animationDuration, () {
            if (mounted) {
              setState(() {
                _isConfettiActive = false;
              });
            }
          });
        }
      });
    }
  }

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

    _checkAllHabitsCompleted();
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

  String _getMedalFromStreak(int streak) {
    if (streak >= 7) return 'gold';
    if (streak >= 4) return 'silver';
    return 'bronze';
  }

  // fungsi menyelesaikan habit
  Future<void> _incrementHabitProgress(Habit habit) async {
    final db = await DatabaseHelper.instance.database;

    // Cek apakah habit sudah selesai
    if (habit.progress >= habit.quantity) return;

    final newProgress = habit.progress + 1;

    int newStreak = habit.streak;
    String newMedal = habit.medal;

    // Kalau progress sudah mencapai target
    if (newProgress >= habit.quantity) {
      newStreak += 1;
      newMedal = _getMedalFromStreak(newStreak);
    }

    await db.update(
      'habits',
      {
        'progress': newProgress,
        'streak': newStreak,
        'medal': newMedal,
      },
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  // reset undo
  Future<void> _resetHabitProgress(Habit habit) async {
    habit.progress = 0;
    await DatabaseHelper.instance.updateHabit(habit);
  }

  // habit complete
  Future<void> _completeHabit(Habit habit) async {
    final db = await DatabaseHelper.instance.database;

    // Kalau sudah selesai, gak usah update lagi
    if (habit.progress >= habit.quantity) return;

    final newStreak = habit.streak + 1;

    await db.update(
      'habits',
      {
        'progress': habit.quantity, // langsung penuh
        'streak': newStreak,
        // medal bisa di-skip dulu ya karena belum dipakai
      },
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  List<Widget> _buildHabitsByTime(String timeLabel) {
    final habitsByTime = _habits
        .where(
            (habit) => habit.timeOfDay.toLowerCase() == timeLabel.toLowerCase())
        .toList();

    return habitsByTime.asMap().entries.map((entry) {
      final habit = entry.value;
      final isLast = entry.key == habitsByTime.length - 1;
      final nextHabitTime =
          isLast ? null : habitsByTime[entry.key + 1].timeOfDay;
      final showLine = !isLast && nextHabitTime == habit.timeOfDay;
      return _buildHabitCard(habit, showLine: showLine);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Hitung total dan completed dari _habits
    final totalTasks = _habits.length;
    final completedTasks =
        _habits.where((habit) => habit.progress >= habit.quantity).length;
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
                            SizedBox(height: 4),
                            Text(
                              "$completedTasks/$totalTasks",
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
                      ..._buildHabitsByTime('pagi'),
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
                      ..._buildHabitsByTime('siang'),
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
                      ..._buildHabitsByTime('malam'),
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

        if (_isConfettiActive)
          Positioned.fill(
            child: AnimatedOpacity(
              duration: _animationDuration,
              opacity: _isConfettiVisible ? 1.0 : 0.0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedSlide(
                      duration: _animationDuration,
                      offset: _isConfettiVisible
                          ? Offset.zero
                          : const Offset(0, 0),
                      child: Transform.translate(
                        offset:
                            Offset(-100, 0), // (X, Y): kanan 20px, atas 50px
                        child: SizedBox(
                          child: Lottie.asset(
                            'assets/animations/confetti.json',
                            repeat: false,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: AnimatedSlide(
                        duration: _animationDuration,
                        offset: _isConfettiVisible
                            ? Offset.zero
                            : const Offset(0, 0.2),
                        child: AnimatedOpacity(
                          duration: _animationDuration,
                          opacity: _isConfettiVisible ? 1.0 : 0.0,
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
                                "You're good today!",
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

  Widget _buildHabitCard(Habit habit, {bool showLine = true}) {
    final isCompleted = habit.progress >= habit.quantity;
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
                color: habit.progress >= habit.quantity
                    ? Colors.green
                    : Colors.white,
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
              ),
              child: habit.progress >= habit.quantity
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),

            // hanya tampil jika showLine true
            if (showLine)
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
              motion: isCompleted ? const BehindMotion() : const DrawerMotion(),
              children: isCompleted
                  ? [
                      SlidableAction(
                        onPressed: (_) async {
                          await _resetHabitProgress(
                              habit); // Set progress ke 0 dan simpan
                          setState(() {});
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
                          await _incrementHabitProgress(habit);
                          _loadHabits();
                        },
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        label: '+1',
                        borderRadius: BorderRadius.circular(12),
                      ),
                      SlidableAction(
                        onPressed: (_) async {
                          await _completeHabit(habit);
                          _loadHabits();
                        },
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        icon: Icons.done_all,
                        label: 'Selesai',
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
            ),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HabitDetailPage(habit: habit),
                  ),
                );

                if (result == true) {
                  _loadHabits(); // <-- ini akan refresh list habit kalau ada perubahan
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.grey.shade200 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isCompleted
                      ? []
                      : [
                          BoxShadow(
                            color: const Color.fromARGB(20, 0, 0, 0),
                            blurRadius: 19,
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.grey.shade400
                            : Color(int.parse(habit.color)).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        IconData(int.parse(habit.icon),
                            fontFamily: 'MaterialIcons'),
                        color: isCompleted
                            ? Colors.white
                            : Color(int.parse(habit.color)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 600),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isCompleted ? Colors.grey : Colors.black,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            child: Text(habit.name),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${habit.progress}/${habit.quantity} ${habit.unit}",
                            style: GoogleFonts.poppins(
                              color: isCompleted
                                  ? Colors.grey
                                  : Color(int.parse(habit.color)),
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
        )
      ],
    );
  }
}
