import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_do_app/models/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = "tasks";

  static Future<void> initDB() async {
    if (_db != null) {
      debugPrint("Not null db");
      return;
    } else {
      // try {
      // String _path = await getDatabasesPath() + "task.db";
      String databasesPath = await getDatabasesPath();
      String _path = databasesPath + "task.db";
      _db = await openDatabase(_path, version: _version,
          onCreate: (Database db, int version) async {
        // When creating the db, create the table
        debugPrint("Create new db");
        await db.execute('CREATE TABLE $_tableName('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'title STRING, '
            'note TEXT, '
            'date STRING, '
            'startTime STRING, '
            'endTime STRING, '
            'remind INTEGER, '
            'repeat STRING, '
            'color INTEGER, '
            'isCompleted INTEGER );');
      });

      debugPrint("_path:$_path");
    }
  }

  static Future<int> delete(Task task) async {
    debugPrint("delete");
    return await _db!.delete(_tableName, where: "id = ?", whereArgs: [task.id]);
  }

  static Future<int> deleteAll() async {
    debugPrint("delete All");
    return await _db!.delete(_tableName);
  }

  static Future<int> insert(Task task) async {
    debugPrint("insert");
    return await _db!.insert(_tableName, task.toJson());
  }

  static Future<int> update(int id) async {
    debugPrint("update");
    return await _db!.rawUpdate("""
      UPDATE tasks SET isCompleted = ? 
      WHERE id = ?
      """, [1, id]);
  }

  static Future<List<Map<String, dynamic>>> querySQL() async {
    debugPrint("Query SQL");
    return await _db!.query(_tableName);
  }
}
