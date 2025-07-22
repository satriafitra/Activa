import 'dart:io';
import 'package:active/models/habit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

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
      unit TEXT DEFAULT 'kali',          -- satuan default 'kali'
      has_reminder INTEGER,
      reminder_time TEXT
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
}
