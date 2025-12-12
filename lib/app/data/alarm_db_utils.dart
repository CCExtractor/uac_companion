import 'package:flutter/foundation.dart';
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
    _database = await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE alarms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      unique_sync_id TEXT NOT NULL UNIQUE,
      time TEXT NOT NULL,
      days TEXT NOT NULL,
      is_enabled INTEGER NOT NULL,
      is_one_time INTEGER NOT NULL DEFAULT 1,
      from_watch INTEGER NOT NULL DEFAULT 1,
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
      location_condition_type INTEGER NOT NULL DEFAULT 0,
      snooze_duration INTEGER NOT NULL DEFAULT 5
    )
  ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add snooze_duration column for existing databases
      await db.execute(
        'ALTER TABLE alarms ADD COLUMN snooze_duration INTEGER NOT NULL DEFAULT 5'
      );
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    return (await db)
        .insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    return (await db).query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data, String uniqueSyncId) async {
    return (await db).update(table, data, where: 'unique_sync_id = ?', whereArgs: [uniqueSyncId]);
  }

  Future<int> deleteByUniqueSyncId(String table, String uniqueSyncId) async {
    return (await db).delete(table, where: 'unique_sync_id = ?', whereArgs: [uniqueSyncId]);
  }
}

class AlarmDBService {
  static const String _table = 'alarms';

  Future<Alarm> insertNewAlarm(Alarm alarm) async {
    final map = alarm.toMap();
    map.remove('id');

    final newId = await DBHelper.instance.insert(_table, map);

    return Alarm(
      id: newId,
      time: alarm.time,
      days: alarm.days,
      isEnabled: alarm.isEnabled,
      isOneTime: alarm.isOneTime,
      fromWatch: alarm.fromWatch,
      uniqueSyncId: alarm.uniqueSyncId,
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
      snoozeDuration: alarm.snoozeDuration,
    );
  }

  Future<List<Alarm>> getAlarms() async {
    final result = await DBHelper.instance.getAll(_table);
    debugPrint("alarm_utils getAlarms: $result");
    return result.map((e) => alarmFromMap(e)).toList();
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await DBHelper.instance.update(_table, alarm.toMap(), alarm.uniqueSyncId!);
  }

  Future<void> deleteAlarm(String uniqueSyncId) async {
    await DBHelper.instance.deleteByUniqueSyncId(_table, uniqueSyncId);
  }
}