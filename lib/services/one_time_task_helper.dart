import 'package:sqflite/sqflite.dart';
import 'package:active/services/database_helper.dart';
import 'package:active/models/one_time_task.dart';


class OneTimeTaskHelper {
  static const tableName = 'one_time_tasks';

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
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
  }

  static Future<int> insert(OneTimeTask task) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert(tableName, task.toMap());
  }

  static Future<List<OneTimeTask>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(tableName, orderBy: 'date ASC');
    return maps.map((e) => OneTimeTask.fromMap(e)).toList();
  }

  static Future<int> update(OneTimeTask task) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      tableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
