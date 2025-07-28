import 'package:active/models/HabitWithStatus.dart';
import 'package:active/pages/habit_detail_page.dart';
import 'package:active/components/sidebar.dart';
import 'package:active/components/confetti_overlay.dart';
import 'package:active/components/habit_card.dart';
import 'package:active/pages/habit_list/habit_list_utils.dart';
import 'package:active/pages/habit_list/habit_list_logic.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:active/services/database_helper.dart';
import 'package:active/models/habit.dart';
import 'package:active/pages/add_habit_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'visual_feedback.dart';

class HabitListPage extends StatefulWidget {
  @override
  _HabitListPageState createState() => _HabitListPageState();
}

class _HabitListPageState extends State<HabitListPage> {
  late DatabaseHelper dbHelper;

  // realtime image
  final image = getTimeBasedBannerImage();
  final greeting = getGreeting();
  final weekday = DateTime.now().weekday;

  int _completedTasks = 0;
  int _totalTasks = 0;

  void debugPrintHabitLogs() async {
    final db = await dbHelper.database;
    final logs = await db.query('habit_logs');

    for (var log in logs) {
      print(
          '📋 LOG => id: ${log['id']}, habit_id: ${log['habit_id']}, date: "${log['date']}", qty: ${log['quantity_completed']}');
    }
  }

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

  // load habit logic
  void _loadHabitsForDate(DateTime date) async {
    final habitStatuses = await loadHabitsForDate(
      date: date,
      dbHelper: dbHelper,
    );

    final completedTasks = habitStatuses.where((h) => h.isCompleted).length;
    final totalTasks = habitStatuses.length;

    setState(() {
      habitsWithStatus = habitStatuses;
      _completedTasks = completedTasks;
      _totalTasks = totalTasks;
    });

    _checkAllHabitsCompleted();
    debugPrintHabitLogs();
  }

  DateTime selectedDate = DateTime.now();
  late final String _dayName;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isConfettiActive = false; // Untuk munculin widget
  bool _isConfettiVisible = false; // Untuk mengatur opacity/slide

  final Duration _animationDuration = Duration(milliseconds: 500);

  // tampilkan overlay confetti

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

                // 🎖️ Tampilkan streak overlay
                showStreakOverlay(context);
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

  late String _day;

  @override
  void initState() {
    super.initState();
    _day = getDayName(DateTime.now().weekday);
    dbHelper = DatabaseHelper.instance; // ✅
    // ✅ inisialisasi dbHelper

    selectedDate = DateTime.now(); // ✅ penting untuk awal tampilan
    _dayName = getDayName(selectedDate.weekday);

    _loadHabitsForDate(selectedDate); // ✅ load habit berdasarkan tanggal awal
  }

  Future<void> _loadHabits() async {
    final allHabits = await DatabaseHelper.instance.getHabits();

    final today = getDayName(DateTime.now().weekday);

    final todaysHabits = allHabits.where((habit) {
      return habit.days.contains(today);
    }).toList();

    setState(() {
      habitsWithStatus = todaysHabits
          .map((habit) => HabitWithStatus(
              habit: habit,
              isCompleted: false,
              quantityCompleted: 0)) // ✅ fix error
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
    final lowerTimeLabel = timeLabel.toLowerCase();

    final filteredHabits = habitsWithStatus
        .where(
          (h) => h.habit.timeOfDay.toLowerCase() == lowerTimeLabel,
        )
        .toList();

    return List.generate(filteredHabits.length, (index) {
      final habitStatus = filteredHabits[index];
      final habit = habitStatus.habit;
      final isCompleted = habitStatus.isCompleted;
      final quantity = habitStatus.quantityCompleted;

      final isLast = index == filteredHabits.length - 1;
      final nextHabitTime =
          !isLast ? filteredHabits[index + 1].habit.timeOfDay : null;
      final showLine = !isLast && nextHabitTime == habit.timeOfDay;

      return HabitCard(
        habit: habit,
        isCompleted: isCompleted,
        isTodaySelected: isTodaySelected,
        selectedDate: selectedDate,
        quantityCompleted: quantity,
        showLine: showLine,
        onReload: () => _loadHabitsForDate(selectedDate),
        onConfettiCheck: (shouldCheck) {
          setState(() {
            _shouldCheckConfetti = shouldCheck;
          });
        },
      );
    });
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

              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(
                      image: AssetImage(
                        isTodaySelected
                            ? image.toString()
                            : 'assets/images/banner_unc.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      // 🔼 Kiri atas: sapaan
                      if (isTodaySelected)
                        Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Hi, ",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                greeting.toString(),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 🔽 Kiri bawah: TASK COMPLETE
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TASK COMPLETE",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$_completedTasks/$_totalTasks",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 🔽 Kanan bawah: motivasi jika BUKAN hari ini
                      if (!isTodaySelected)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            "New day, new chances.",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
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
                        key: ValueKey('pagi-${selectedDate.toIso8601String()}'),
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
                        key:
                            ValueKey('siang-${selectedDate.toIso8601String()}'),
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
                        key:
                            ValueKey('malam-${selectedDate.toIso8601String()}'),
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

        // show confetti
        if (_isConfettiActive)
          ConfettiOverlay(
            isVisible: _isConfettiVisible,
            animationDuration: _animationDuration,
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
}
