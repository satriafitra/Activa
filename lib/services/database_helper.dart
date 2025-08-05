import 'dart:io';
import 'package:active/models/habit.dart';
import 'package:active/services/one_time_task_helper.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:active/pages/habit_list/habit_list_utils.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'activa.db');

    // UPGRADE PROGRESS

    Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        await db.execute(
            'ALTER TABLE habits ADD COLUMN progress INTEGER DEFAULT 0');
      }
    }

    return await openDatabase(
      path,
      version: 2, // dari 1 → 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // tambahkan ini
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE habits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      icon TEXT,
      color TEXT,
      time_of_day TEXT,
      days TEXT,
      streak INTEGER DEFAULT 0,
      medal TEXT DEFAULT 'bronze',
      quantity INTEGER DEFAULT 1,        -- kuantitas default 1
      progress INTEGER DEFAULT 0,
      unit TEXT DEFAULT 'kali',          -- satuan default 'kali'
      has_reminder INTEGER,
      reminder_time TEXT,
      current_streak INTEGER DEFAULT 0,
      longest_streak INTEGER DEFAULT 0
    )

    
  ''');

    await db.execute('''
    CREATE TABLE habit_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      habit_id INTEGER,
      date TEXT,
      quantity_completed INTEGER DEFAULT 0,
      FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
    )
  ''');

    await OneTimeTaskHelper.createTable(db);
  }

  // Habit Create
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  // Habit Read All
  Future<List<Habit>> getHabits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('habits');
    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  // update habit
  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  // Delete habit
  Future<int> deleteHabit(int id) async {
    final db = await database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // nagmbil id by id hehe
  Future<Habit?> getHabitById(int id) async {
    final db = await database;
    final maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Habit>> getHabitsForDate(DateTime date) async {
    final db = await database;

    // Format tanggal untuk nanti dipakai cek log (kalau mau disesuaikan)
    final dateString = date.toIso8601String().substring(0, 10);

    // Untuk sekarang kita ambil semua habit aja
    final result = await db.query(
        'habits'); // Bisa tambahkan where jika kamu punya field active, dll.

    return result.map((map) => Habit.fromMap(map)).toList();
  }

  // ✅ Cek apakah habit sudah selesai di tanggal tertentu
  Future<bool> isHabitCompleted(int habitId, String date) async {
    final db = await database;
    final result = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, date],
    );
    return result.isNotEmpty;
  }

// ✅ Tandai habit selesai di tanggal tertentu
  Future<void> markHabitAsCompleted(int habitId, String date) async {
    final db = await database;

    final habit = await getHabitById(habitId);
    if (habit == null) return;

    final int quantity = habit.quantity;

    // ⛔ Cek dulu: apakah sudah pernah ditandai selesai hari ini?
    final alreadyCompleted =
        await isHabitCompletedOnDate(habitId, DateTime.parse(date));
    if (alreadyCompleted) {
      // ✅ Sudah pernah, cukup update progress doang (atau bahkan skip)
      return;
    }

    // ✅ Masukkan ke habit_logs
    await db.insert(
      'habit_logs',
      {
        'habit_id': habitId,
        'date': date,
        'quantity_completed': quantity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ✅ Cek apakah habit selesai di tanggal tertentu (dengan parameter DateTime)
  Future<bool> isHabitCompletedOnDate(int habitId, DateTime date) async {
    final db = await database;
    final dateString =
        date.toIso8601String().substring(0, 10); // Format: yyyy-MM-dd
    final result = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ? AND quantity_completed > 0',
      whereArgs: [habitId, dateString],
    );
    return result.isNotEmpty;
  }

  Future<void> unmarkHabitAsCompleted(int habitId, String date) async {
    final db = await database;

    // Ambil quantity dari habit
    final habit = await getHabitById(habitId);
    if (habit == null) return;

    final int quantity = habit.quantity;

    // Hapus dari habit_logs
    await db.delete(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, date],
    );

    // Kurangi progress di habits
    await db.rawUpdate(
      '''
    UPDATE habits
    SET progress = MAX(progress - ?, 0) -- supaya ga minus
    WHERE id = ?
    ''',
      [quantity, habitId],
    );
  }

  Future<int> getQuantityCompletedOnDate(int habitId, String date) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
    SELECT SUM(quantity_completed) as total
    FROM habit_logs
    WHERE habit_id = ? AND date = ?
    ''',
      [habitId, date],
    );

    int qty = 0;

    if (result.isNotEmpty) {
      qty = result.first['total'] == null ? 0 : result.first['total'] as int;
    }

    print('🎯 Total qty pada $date untuk habit $habitId = $qty');
    return qty;
  }

  // nambah habit multidays hanya masa depan

  Future<void> generateHabitLogs({
    required int habitId,
    required List<int> repeatDays,
    int daysForward = 30,
  }) async {
    final db = await database;
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');

    for (int i = 0; i <= daysForward; i++) {
      final date =
          DateTime(now.year, now.month, now.day).add(Duration(days: i));

      final weekday = date.weekday;

      print("🔄 Cek tanggal: ${formatter.format(date)} (weekday: $weekday)");

      if (!repeatDays.contains(weekday)) continue;

      final formattedDate = formatter.format(date);

      final exists = await db.query(
        'habit_logs',
        where: 'habit_id = ? AND date = ?',
        whereArgs: [habitId, formattedDate],
      );

      if (exists.isEmpty) {
        print('🆕 INSERT log for $formattedDate');
        await db.insert('habit_logs', {
          'habit_id': habitId,
          'date': formattedDate,
          'quantity_completed': 0,
        });
      }
    }
  }

  Future<bool> isHabitLogExist(int habitId, DateTime date) async {
    final db = await database;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final result = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateStr],
    );
    return result.isNotEmpty;
  }

  // logika filter masa lalu berdasar log
  Future<bool> isHabitExistInLogOnDate(int habitId, String date) async {
    final db = await database;
    final result = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, date],
    );
    return result.isNotEmpty;
  }


  Future<void> updateGlobalStreak(DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = selectedDate.toIso8601String().substring(0, 10);
    final lastStreakDate = prefs.getString('lastStreakDate');

    if (lastStreakDate == todayStr) return;

    final habitsToday =
        await getHabitsForDate(selectedDate); // ✅ pakai internal method

    if (habitsToday.isEmpty) return;

    bool allCompleted = true;
    for (final habit in habitsToday) {
      final isCompleted = await isHabitCompletedOnDate(
          habit.id!, selectedDate); // ✅ pakai internal method
      if (!isCompleted) {
        allCompleted = false;
        break;
      }
    }

    if (allCompleted) {
      final yesterdayStr = selectedDate
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .substring(0, 10);

      int current = prefs.getInt('currentStreak') ?? 0;
      int longest = prefs.getInt('longestStreak') ?? 0;

      current = (lastStreakDate == yesterdayStr) ? current + 1 : 1;
      longest = current > longest ? current : longest;

      await prefs.setInt('currentStreak', current);
      await prefs.setInt('longestStreak', longest);
      await prefs.setString('lastStreakDate', todayStr);

      print("✅ Global streak updated!");
      print("🔥 Current streak: $current");
      print("🏆 Longest streak: $longest");
    }
  }

  Future<void> checkAndResetStreaks() async {
    print('🔍 Memulai pengecekan reset streak...');

    final db = await database;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final todayStr = today.toIso8601String().substring(0, 10);
    final yesterdayStr = yesterday.toIso8601String().substring(0, 10);

    final allHabits = await getAllHabits();

    for (final habit in allHabits) {
      final activeDays = habit.dayList;
      final todayDay = getDayName(today.weekday);
      final yesterdayDay = getDayName(yesterday.weekday);

      final isActiveToday = activeDays.contains(todayDay);
      final wasActiveYesterday = activeDays.contains(yesterdayDay);

      final completedYesterday =
          await isHabitCompletedOnDate(habit.id!, yesterday);
      final completedToday = await isHabitCompletedOnDate(habit.id!, today);

      // 🔍 Tambahan debug untuk memastikan ada log atau tidak kemarin
      final totalQty =
          await getHabitCompletionQuantity(habit.id!, yesterdayStr);
      print(
          '🔎 Total qty log kemarin (${yesterdayStr}) untuk ${habit.name} = $totalQty');

      print('🧠 Evaluasi habit: ${habit.name}');
      print('📋 Active days: $activeDays');
      print(
          '📆 Kemarin: $yesterdayStr ($yesterdayDay), wasActiveYesterday: $wasActiveYesterday');
      print(
          '📆 Hari ini: $todayStr ($todayDay), isActiveToday: $isActiveToday');
      print('✔️ completedYesterday: $completedYesterday');
      print('✔️ completedToday: $completedToday');

      if (wasActiveYesterday && !completedYesterday) {
        await db.update(
          'habits',
          {
            'current_streak': 0,
          },
          where: 'id = ?',
          whereArgs: [habit.id],
        );

        print(
          '🔁 Streak habit "${habit.name}" di-reset ke 0 karena hari ini ($todayStr) adalah hari aktif dan tidak dikerjakan.',
        );
      }
    }
  }

  Future<int> getHabitCompletionQuantity(int habitId, String date) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT SUM(quantity_completed) as total
    FROM habit_logs
    WHERE habit_id = ? AND date = ?
  ''', [habitId, date]);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final result = await db.query('habits');
    return result.map((map) => Habit.fromMap(map)).toList();
  }

  Future<void> runStreakResetOncePerDay() async {
    print('📌 Memulai pengecekan reset streak harian...');

    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    final lastReset = prefs.getString('last_streak_reset_date');

    if (lastReset != todayStr) {
      // Jalankan reset streak
      await checkAndResetStreaks();

      // Simpan tanggal hari ini sebagai tanggal terakhir reset
      await prefs.setString('last_streak_reset_date', todayStr);

      print('✅ Reset streak berhasil dijalankan hari ini');
    } else {
      print('ℹ️ Reset streak sudah dijalankan hari ini ($todayStr), skip.');
    }
  }

  // undo streak saat user menambah habit baru di hari ini

  Future<void> undoStreakIfNeeded(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = date.toIso8601String().substring(0, 10);
    final lastStreakDate = prefs.getString('lastStreakDate');

    // Cek apakah streak pernah ditambahkan hari ini
    if (lastStreakDate != todayStr) return;

    final habitsToday = await getHabitsForDate(date);
    if (habitsToday.isEmpty) return;

    bool allCompleted = true;
    for (final habit in habitsToday) {
      final isCompleted = await isHabitCompletedOnDate(habit.id!, date);
      if (!isCompleted) {
        allCompleted = false;
        break;
      }
    }

    // Kalau sekarang sudah tidak semua habit selesai, undo streak
    if (!allCompleted) {
      int current = prefs.getInt('currentStreak') ?? 0;

      if (current > 0) {
        await prefs.setInt('currentStreak', current - 1);
        await prefs.remove(
            'lastStreakDate'); // biar bisa update ulang kalau nanti diselesaikan semua

        print(
            "🔁 Global streak di-undo karena ada habit baru yang belum selesai");
        print("🔥 Current streak sekarang: ${current - 1}");
      }
    }
  }
}
