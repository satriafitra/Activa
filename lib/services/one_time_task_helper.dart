import 'package:sqflite/sqflite.dart';
import 'package:active/services/database_helper.dart';
import 'package:active/models/one_time_task.dart';

class OneTimeTaskHelper {
  static const oneTimeTask = 'one_time_tasks';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $oneTimeTask (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        date TEXT NOT NULL,
        quantity INTEGER,
        unit TEXT,
        has_reminder INTEGER,
        reminder_time TEXT
      )
    ''');

    await db.execute('''
  ALTER TABLE $oneTimeTask ADD COLUMN is_completed INTEGER DEFAULT 0
''');
  }

  static Future<int> insert(OneTimeTask task) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(oneTimeTask, task.toMap());
  }

  static Future<List<OneTimeTask>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(oneTimeTask, orderBy: 'date ASC');
    return maps.map((e) => OneTimeTask.fromMap(e)).toList();
  }

  static Future<int> update(OneTimeTask task) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      oneTimeTask,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(oneTimeTask, where: 'id = ?', whereArgs: [id]);
  }

  // Tandai one-time task sebagai selesai
  Future<void> markOneTimeTaskAsCompleted(int taskId) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'one_time_tasks',
      {'is_completed': 1},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

// Kembalikan (undo) one-time task jadi belum selesai
  Future<void> unmarkOneTimeTaskAsCompleted(int taskId) async {
    final db = await DatabaseHelper.instance.database;

    await db.update(
      'one_time_tasks',
      {'is_completed': 0},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<List<OneTimeTask>> getOneTimeTasksByDate(String date) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'one_time_tasks',
      where: 'date = ? AND is_completed = 0',
      whereArgs: [date],
    );

    return maps.map((map) => OneTimeTask.fromMap(map)).toList();
  }
}
