import 'dart:io';
import 'package:active/models/habit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

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
      reminder_time TEXT
    )

    
  ''');

    await db.execute('''
    CREATE TABLE habit_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      habit_id INTEGER,
      date TEXT,
      quantity_completed INTEGER DEFAULT 1,
      FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE
    )
  ''');
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

    await db.insert(
      'habit_logs',
      {
        'habit_id': habitId,
        'date': date,
        'quantity_completed': quantity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.rawUpdate(
      '''
    UPDATE habits
    SET progress = progress + ?
    WHERE id = ?
    ''',
      [quantity, habitId],
    );
  }

  // ✅ Cek apakah habit selesai di tanggal tertentu (dengan parameter DateTime)
  Future<bool> isHabitCompletedOnDate(int habitId, DateTime date) async {
    final db = await database;
    final dateString =
        date.toIso8601String().substring(0, 10); // Format: yyyy-MM-dd
    final result = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
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
    final result = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, date],
    );

    if (result.isNotEmpty) {
      return result.first['quantity_completed'] as int;
    }
    return 0;
  }
}
