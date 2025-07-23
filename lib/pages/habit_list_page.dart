import 'package:active/models/HabitWithStatus.dart';
import 'package:active/pages/habit_detail_page.dart';
import 'package:active/components/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:active/services/database_helper.dart';
import 'package:active/models/habit.dart';
import 'package:active/pages/add_habit_page.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';

class HabitListPage extends StatefulWidget {
  @override
  _HabitListPageState createState() => _HabitListPageState();
}

class _HabitListPageState extends State<HabitListPage> {
  late DatabaseHelper dbHelper;

  Map<int, bool> _completedStatus = {};

  bool get isTodaySelected {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  // initiate

  bool _wasAllCompleted = false;
  bool _shouldCheckConfetti = false;

  List<HabitWithStatus> habitsWithStatus = [];

  void _loadHabitsForDate(DateTime date) async {
    final allHabits = await dbHelper.getHabits();
    final selectedDay = DateFormat('EEEE', 'id_ID').format(date);

    print('📆 Hari yang difilter: $selectedDay');

    final filtered = allHabits.where((habit) {
      final days = habit.days.split(',');
      return days.contains(selectedDay);
    }).toList();

    print('🎯 Habit yang cocok di hari ini: ${filtered.length}');

    final habitStatuses = await Future.wait(filtered.map((habit) async {
      final isCompleted =
          await dbHelper.isHabitCompletedOnDate(habit.id!, date);
      print('🔄 Status Habit "${habit.name}" di $date => $isCompleted');
      return HabitWithStatus(habit: habit, isCompleted: isCompleted);
    }));

    setState(() {
      habitsWithStatus = habitStatuses;
    });

    // ✅ Panggil setelah setState
    _checkAllHabitsCompleted();
  }

  void _triggerConfetti() {
    setState(() {
      _isConfettiActive = true;
      _isConfettiVisible = true;
    });

    // otomatis hilang setelah beberapa detik
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isConfettiVisible = false;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _isConfettiActive = false;
        });
      });
    });
  }

  DateTime selectedDate = DateTime.now();

  late final String _dayName;

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

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
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final selected = DateFormat('yyyy-MM-dd').format(selectedDate);

    final isToday = today == selected;
    print('📆 Mengecek confetti untuk: $selected (isToday: $isToday)');

    if (!isToday) {
      print('❌ Bukan hari ini, confetti tidak dicek.');
      return;
    }

    // Ambil nama hari
    final selectedDay = DateFormat('EEEE', 'id_ID').format(selectedDate);
    print('📅 Nama hari saat ini: $selectedDay');

    // Filter hanya habit yang aktif di hari ini
    final todayHabits = habitsWithStatus.where((habit) {
      final days = habit.habit.days.split(',');
      return days.contains(selectedDay);
    }).toList();

    print('🟦 Jumlah habit aktif hari ini: ${todayHabits.length}');
    print(
        '✅ Jumlah habit yang selesai: ${todayHabits.where((h) => h.isCompleted).length}');

    final allCompleted = todayHabits.isNotEmpty &&
        todayHabits.every((habit) => habit.isCompleted == true);

    print('✅ allCompleted: $allCompleted');
    print('❓ _wasAllCompleted: $_wasAllCompleted');
    print('❓ _shouldCheckConfetti: $_shouldCheckConfetti');

    if (allCompleted && !_wasAllCompleted && _shouldCheckConfetti) {
      print('🎉 Semua habit selesai! Menjalankan confetti...');

      _wasAllCompleted = true;
      _shouldCheckConfetti = false;

      if (!_isConfettiActive) {
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

        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isConfettiVisible = false;
            });

            Future.delayed(_animationDuration, () {
              if (mounted) {
                setState(() {
                  _isConfettiActive = false;
                });
                print('🎊 Confetti selesai.');
              }
            });
          }
        });
      }
    } else {
      if (!allCompleted) {
        print('⏳ Belum semua habit selesai.');
        _wasAllCompleted = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance; // ✅
    // ✅ inisialisasi dbHelper

    selectedDate = DateTime.now(); // ✅ penting untuk awal tampilan
    _dayName = _getDayName(selectedDate.weekday);

    _loadHabitsForDate(selectedDate); // ✅ load habit berdasarkan tanggal awal
  }

  Future<void> _loadHabits() async {
    final allHabits = await DatabaseHelper.instance.getHabits();

    final today = _getDayName(DateTime.now().weekday);

    final todaysHabits = allHabits.where((habit) {
      return habit.days.contains(today);
    }).toList();

    setState(() {
      habitsWithStatus = todaysHabits
          .map((habit) => HabitWithStatus(
              habit: habit,
              isCompleted: false)) // atau default sesuai konteksmu
          .toList();
    });

    _checkAllHabitsCompleted();
  }

  bool _isSidebarOpen = false;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  // fungsi menyelesaikan habit
  Future<void> _incrementHabitProgress(Habit habit) async {
    final db = await DatabaseHelper.instance.database;

    // Cek apakah habit sudah selesai
    if (habit.progress >= habit.quantity) return;

    final newProgress = habit.progress + 1;

    int newStreak = habit.streak;
    String newMedal = habit.medal;

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
    final habitsByTime = habitsWithStatus
        .where((habitWithStatus) =>
            habitWithStatus.habit.timeOfDay.toLowerCase() ==
            timeLabel.toLowerCase())
        .toList();

    return habitsByTime.asMap().entries.map<Widget>((entry) {
      final habitWithStatus = entry.value;
      final habit = habitWithStatus.habit;
      final isCompleted = habitWithStatus.isCompleted;

      final isLast = entry.key == habitsByTime.length - 1;
      final nextHabitTime =
          isLast ? null : habitsByTime[entry.key + 1].habit.timeOfDay;
      final showLine = !isLast && nextHabitTime == habit.timeOfDay;

      return _buildHabitCard(habit, isCompleted, showLine: showLine);
    }).toList();
  }

  // FRONT VIEW

  @override
  Widget build(BuildContext context) {
    // Hitung total dan completed dari habitsWithStatus
    final totalTasks = habitsWithStatus.length;
    final completedTasks = habitsWithStatus
        .where((habit) => habit.habit.progress >= habit.habit.quantity)
        .length;
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
                    Text(
                      selectedDate.day == DateTime.now().day &&
                              selectedDate.month == DateTime.now().month &&
                              selectedDate.year == DateTime.now().year
                          ? 'Today'
                          : DateFormat('EEEE, d MMMM', 'id_ID')
                              .format(selectedDate),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                  children: ['S', 'S', 'R', 'K', 'J', 'S', 'M']
                      .map((day) => Text(day, style: GoogleFonts.poppins()))
                      .toList(),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  final date = DateTime.now()
                      .subtract(Duration(days: DateTime.now().weekday - 1 - i));
                  final isSelected = date.day == selectedDate.day &&
                      date.month == selectedDate.month &&
                      date.year == selectedDate.year;

                  return GestureDetector(
                    onTap: () {
                      print('🗓️ Tanggal diklik: $date');
                      setState(() {
                        selectedDate = date;
                        _loadHabitsForDate(selectedDate);
                      });
                    },
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
                              date.day.toString().padLeft(2, '0'),
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
              isTodaySelected
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: DecorationImage(
                            image: AssetImage('assets/images/banner.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Stack(
                          children: [
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
                    )
                  : const SizedBox.shrink(),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (habitsWithStatus.any(
                        (h) => h.habit.timeOfDay.toLowerCase() == 'pagi')) ...[
                      Text(
                        "MORNING",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color.fromARGB(132, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        key: ValueKey(
                            'pagi-${selectedDate.toIso8601String()}'),
                        children: _buildHabitsByTime('pagi'),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (habitsWithStatus.any(
                        (h) => h.habit.timeOfDay.toLowerCase() == 'siang')) ...[
                      Text(
                        "AFTERNOON",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color.fromARGB(132, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        key: ValueKey(
                            'siang-${selectedDate.toIso8601String()}'),
                        children: _buildHabitsByTime('siang'),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (habitsWithStatus.any(
                        (h) => h.habit.timeOfDay.toLowerCase() == 'malam')) ...[
                      Text(
                        "EVENING",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color.fromARGB(132, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        key: ValueKey(
                            'malam-${selectedDate.toIso8601String()}'),
                        children: _buildHabitsByTime('malam'),
                      ),
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
                      offset:
                          _isConfettiVisible ? Offset.zero : const Offset(0, 0),
                      child: Transform.translate(
                        offset:
                            Offset(-115, 0), // (X, Y): kanan 20px, atas 50px
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
          ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddHabitPage()),
          );
          _loadHabitsForDate(selectedDate);
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

  Widget _buildHabitCard(Habit habit, bool isCompleted,
      {bool showLine = true}) {
    final isInactiveDay = !isTodaySelected;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress circle kiri
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.white,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: isCompleted
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
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

        // Slidable
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
                              await dbHelper.unmarkHabitAsCompleted(
                                habit.id!,
                                DateFormat('yyyy-MM-dd').format(selectedDate),
                              );
                              _loadHabitsForDate(selectedDate);
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
                              await dbHelper.markHabitAsCompleted(
                                habit.id!,
                                DateFormat('yyyy-MM-dd').format(selectedDate),
                              );

                              setState(() {
                                _shouldCheckConfetti =
                                    true; // <-- Tambahkan ini!
                              });

                              _loadHabitsForDate(selectedDate);
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.check,
                            label: 'Selesai',
                          ),
                        ]
                  : [], // Tidak bisa menyelesaikan habit di hari lain
            ),
            child: InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitDetailPage(habit: habit),
                    ),
                  );
                  if (result == true) _loadHabitsForDate(selectedDate);
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: isInactiveDay
                        ? Colors.grey.shade200 // warna card nonaktif
                        : (isCompleted ? Colors.grey.shade200 : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isInactiveDay || isCompleted
                        ? [] // tanpa shadow jika nonaktif atau sudah selesai
                        : [
                            BoxShadow(
                              color: const Color.fromARGB(20, 0, 0, 0),
                              blurRadius: 19,
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      // Icon box
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
                                    : (isCompleted
                                        ? Colors.grey
                                        : Colors.black),
                                decoration: isCompleted && !isInactiveDay
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                              child: Text(habit.name),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isInactiveDay
                                  ? "${habit.quantity} ${habit.unit}"
                                  : "${habit.progress}/${habit.quantity} ${habit.unit}",
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
                )),
          ),
        ),
      ],
    );
  }
}
