import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'alarm_model.dart';

// Database helper class for managing SQLite operations
class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get db async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'wear_alarms.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDB);
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT NOT NULL,
        days TEXT NOT NULL,
        enabled INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    return (await db).insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    return (await db).query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    return (await db).update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteById(String table, int id) async {
    return (await db).delete(table, where: 'id = ?', whereArgs: [id]);
  }
}

// Alarm Services or Funcitons
class AlarmDBService {
  static const String _table = 'alarms';
  Future<Alarm> insertNewAlarm(Alarm alarm) async {
    final map = alarm.toMap();
    map.remove('id');
    final rawId = await DBHelper.instance.insert(_table, map);

    //** Need offset in order to avoid conflict while syncing with UAC
    var offsetId = rawId;
    if(rawId == 1) {
      offsetId = rawId + 10000;
    }
    
    await DBHelper.instance.update(_table, {'id': offsetId}, rawId);

    return Alarm(
      id: offsetId,
      time: alarm.time,
      days: alarm.days,
      enabled: alarm.enabled,
    );
  }

  Future<List<Alarm>> getAlarms() async {
    final result = await DBHelper.instance.getAll(_table);
    debugPrint("alarm_utils getAlarms: $result");
    return result.map((e) => alarmFromMap(e)).toList();
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await DBHelper.instance.update(_table, alarm.toMap(), alarm.id!);
  }

  Future<void> deleteAlarm(int id) async {
    await DBHelper.instance.deleteById(_table, id);
  }
}