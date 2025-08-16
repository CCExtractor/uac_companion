import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'alarm_model.dart';

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

  // Future _createDB(Database db, int version) async {
  //   await db.execute('''
  //     CREATE TABLE alarms (
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       time TEXT NOT NULL,
  //       days TEXT NOT NULL,
  //       is_enabled INTEGER NOT NULL,
  //       is_one_time INTEGER NOT NULL DEFAULT 1,
  //       from_watch INTEGER NOT NULL DEFAULT 1,
  //       is_location_enabled INTEGER NOT NULL DEFAULT 0,
  //       location TEXT DEFAULT '',
  //       is_guardian INTEGER NOT NULL DEFAULT 0,
  //       guardian TEXT DEFAULT '',
  //       guardian_timer INTEGER NOT NULL DEFAULT 0,
  //       is_call INTEGER NOT NULL DEFAULT 0
  //     )
  //   ''');
  // }
  Future _createDB(Database db, int version) async {
  await db.execute('''
    CREATE TABLE alarms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      time TEXT NOT NULL,
      days TEXT NOT NULL,
      is_enabled INTEGER NOT NULL,
      is_one_time INTEGER NOT NULL DEFAULT 1,
      from_watch INTEGER NOT NULL DEFAULT 1,
      watch_id INTEGER NOT NULL DEFAULT -1,

      -- Screen Activity
      is_activity_enabled INTEGER NOT NULL DEFAULT 0,
      activity_interval INTEGER NOT NULL DEFAULT 0,
      activity_condition_type INTEGER NOT NULL DEFAULT 0,

      -- Guardian Angel
      is_guardian INTEGER NOT NULL DEFAULT 0,
      guardian TEXT DEFAULT '',
      guardian_timer INTEGER NOT NULL DEFAULT 0,
      is_call INTEGER NOT NULL DEFAULT 0,

      -- Weather Condition
      is_weather_enabled INTEGER NOT NULL DEFAULT 0,
      weather_condition_type INTEGER NOT NULL DEFAULT 0,
      weather_types TEXT DEFAULT '',

      -- Location Condition
      is_location_enabled INTEGER NOT NULL DEFAULT 0,
      location TEXT DEFAULT '',
      location_condition_type INTEGER NOT NULL DEFAULT 0
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

  Future<Alarm> insertNewAlarm(Alarm alarm) async {
    final map = alarm.toMap();
    map.remove('id');
    final rawId = await DBHelper.instance.insert(_table, map);

    //** Offset to avoid ID conflict with phone-side alarms
    var offsetId = rawId + 100000;

    // await DBHelper.instance.update(_table, {'id': offsetId}, rawId);
    await DBHelper.instance.update(
      _table,
      {'id': rawId, 'watch_id': offsetId},
      rawId,
    );


    return Alarm(
      id: rawId,
      time: alarm.time,
      days: alarm.days,
      isEnabled: alarm.isEnabled,
      isOneTime: alarm.isOneTime,
      fromWatch: alarm.fromWatch,
      watchId: offsetId,

      isActivityEnabled: alarm.isActivityEnabled,
      activityInterval: alarm.activityInterval,
      activityConditionType: alarm.activityConditionType,

      isGuardian: alarm.isGuardian,
      guardian: alarm.guardian,
      guardianTimer: alarm.guardianTimer,
      isCall: alarm.isCall,

      isWeatherEnabled: alarm.isWeatherEnabled,
      weatherConditionType: alarm.weatherConditionType,
      weatherTypes: alarm.weatherTypes,

      isLocationEnabled: alarm.isLocationEnabled,
      location: alarm.location,
      locationConditionType: alarm.locationConditionType,
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