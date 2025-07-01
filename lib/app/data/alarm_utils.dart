import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'alarm_model.dart';

Alarm alarmFromMap(Map<String, dynamic> map) {
  final rawDays = map['days'];
  List<int> parsedDays = [];

  if (rawDays is String && rawDays.isNotEmpty) {
    parsedDays = rawDays
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
  }

  return Alarm(
    id: map['id'],
    time: map['time'],
    days: parsedDays,
    enabled: map['enabled'] == 1,
  );
}

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

class AlarmDBService {
  static const String _table = 'alarms';

  Future<Alarm> insertAlarm(Alarm alarm) async {
    final map = alarm.toMap();
    map.remove('id'); // Remove ID to let DB auto-generate it
    final id = await DBHelper.instance.insert(_table, map);
    return Alarm(
      id: id,
      time: alarm.time,
      days: alarm.days,
      enabled: alarm.enabled,
    );
  }

  Future<List<Alarm>> getAlarms() async {
    final result = await DBHelper.instance.getAll(_table);
    debugPrint("DB getAlarms function: $result");
    return result.map((e) => alarmFromMap(e)).toList();
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await DBHelper.instance.update(_table, alarm.toMap(), alarm.id!);
  }

  Future<void> deleteAlarm(int id) async {
    await DBHelper.instance.deleteById(_table, id);
  }
}
