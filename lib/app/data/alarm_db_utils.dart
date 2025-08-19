import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uac_companion/app/utils/unique_id_generator.dart';
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

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE alarms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      time TEXT NOT NULL,
      days TEXT NOT NULL,
      is_enabled INTEGER NOT NULL,
      is_one_time INTEGER NOT NULL DEFAULT 1,
      from_watch INTEGER NOT NULL DEFAULT 1,
      unique_sync_id TEXT NOT NULL,

      is_activity_enabled INTEGER NOT NULL DEFAULT 0,
      activity_interval INTEGER NOT NULL DEFAULT 0,
      activity_condition_type INTEGER NOT NULL DEFAULT 0,

      is_guardian INTEGER NOT NULL DEFAULT 0,
      guardian TEXT DEFAULT '',
      guardian_timer INTEGER NOT NULL DEFAULT 0,
      is_call INTEGER NOT NULL DEFAULT 0,

      is_weather_enabled INTEGER NOT NULL DEFAULT 0,
      weather_condition_type INTEGER NOT NULL DEFAULT 0,
      weather_types TEXT DEFAULT '',

      is_location_enabled INTEGER NOT NULL DEFAULT 0,
      location TEXT DEFAULT '',
      location_condition_type INTEGER NOT NULL DEFAULT 0
    )
  ''');
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    return (await db)
        .insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
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
    var unique_id_generator = generateUniqueId();

    // await DBHelper.instance.update(_table, {'id': offsetId}, rawId);
    await DBHelper.instance.update(
      _table,
      {'id': rawId, 'unique_sync_id': unique_id_generator},
      rawId,
    );

    return Alarm(
      id: rawId,
      time: alarm.time,
      days: alarm.days,
      isEnabled: alarm.isEnabled,
      isOneTime: alarm.isOneTime,
      fromWatch: alarm.fromWatch,
      uniqueSyncId: unique_id_generator,
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
