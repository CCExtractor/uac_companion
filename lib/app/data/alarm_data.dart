// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class Alarm {
//   final int? id;
//   final String time;
//   final List<int> days;
//   final bool enabled;

//   Alarm({
//     this.id,
//     required this.time,
//     required this.days,
//     this.enabled = true,
//   });

//   Map<String, dynamic> toMap() => {
//     if (id != null) 'id': id, //! never will be null when inserting
//     'time': time,
//     'days': days.join(','),
//     'enabled': enabled ? 1 : 0,
//   };

//   factory Alarm.fromMap(Map<String, dynamic> map) {
//     final daysString = map['days'] as String? ?? '';
//     final daysList = daysString.isEmpty //! might not be needing
//       ? <int>[]
//       : daysString.split(',').where((e) => e.trim().isNotEmpty).map(int.parse).toList();
  
//     return Alarm(
//       id: map['id'] as int?,
//       time: map['time'] as String,
//       days: daysList,
//       enabled: (map['enabled'] == 1),
//     );
//   }

//   @override
//   String toString() => 'Alarm(id: $id, time: $time, days: $days, enabled: $enabled)';
// }

// //! use a defferent file.
// class AlarmDatabase {
//   static final AlarmDatabase instance = AlarmDatabase._init();
//   static Database? _database;

//   AlarmDatabase._init();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB('alarms.db');
//     return _database!;
//   }

//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: createDB,
//     );
//   }

//   Future createDB(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE alarms (
//         id INTEGER PRIMARY KEY,
//         time TEXT NOT NULL,
//         days TEXT NOT NULL,
//         enabled INTEGER NOT NULL
//       )
//     ''');
//   }

//   // Future<Alarm> insertAlarm(Alarm alarm) async {
//   //   final db = await instance.database;
//   //   final id = await db.insert('alarms', alarm.toMap());

//   //   return Alarm(
//   //     id: id,
//   //     time: alarm.time,
//   //     days: alarm.days,
//   //     enabled: alarm.enabled,
//   //   );
//   // }
//   Future<Alarm> insertAlarm(Alarm alarm) async {
//   final db = await instance.database;

//   // Get current max id in DB
//   final maxIdResult = await db.rawQuery('SELECT MAX(id) as max_id FROM alarms');
//   int maxId = maxIdResult.first['max_id'] as int? ?? 10000;

//   // New ID = maxId + 1
//   final newId = maxId + 1;

//   // Create new Alarm with manual ID
//   final alarmWithId = Alarm(
//     id: newId,
//     time: alarm.time,
//     days: alarm.days,
//     enabled: alarm.enabled,
//   );

//   // Insert with manual ID
//   await db.insert('alarms', alarmWithId.toMap());

//   return alarmWithId;
// }

//   Future<List<Alarm>> getAlarms() async {
//     final db = await instance.database;
//     final result = await db.query('alarms');
//     debugPrint("DB query result: $result");
//     return result.map((json) => Alarm.fromMap(json)).toList();
//   }

//   Future<int> updateAlarm(Alarm alarm) async {
//     final db = await instance.database;
//     return await db.update(
//       'alarms',
//       alarm.toMap(),
//       where: 'id = ?',
//       whereArgs: [alarm.id],
//     );
//   }

//   Future<void> deleteAlarm(int id) async {
//   final db = await instance.database;
//   await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
// }
// }