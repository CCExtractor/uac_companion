import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Alarm {
  final int? id;
  final String time;
  final String days;
  final bool enabled;

  Alarm({
    this.id,
    required this.time,
    required this.days,
    this.enabled = true,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'time': time,
      'days': days,
      'enabled': enabled ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id as Object;
    }
    return map;
  }

  factory Alarm.fromMap(Map<String, dynamic> map) => Alarm(
        id: map['id'],
        time: map['time'],
        days: map['days'],
        enabled: map['enabled'] == 1,
      );
}

class AlarmDatabase {
  static final AlarmDatabase instance = AlarmDatabase._init();
  static Database? _database;

  AlarmDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alarms.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
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

  Future<Alarm> insertAlarm(Alarm alarm) async {
    final db = await instance.database;
    final id = await db.insert('alarms', alarm.toMap());

    return Alarm(
      id: id,
      time: alarm.time,
      days: alarm.days,
      enabled: alarm.enabled,
    );
  }

  Future<List<Alarm>> getAlarms() async {
    final db = await instance.database;
    final result = await db.query('alarms');
    return result.map((json) => Alarm.fromMap(json)).toList();
  }

  Future<int> updateAlarm(Alarm alarm) async {
    final db = await instance.database;
    return await db.update(
      'alarms',
      alarm.toMap(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }

  Future<void> deleteAlarm(int id) async {
  final db = await instance.database;
  await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
}

}
