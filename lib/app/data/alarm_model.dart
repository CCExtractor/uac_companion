class Alarm {
  final int? id; //* ID is nullable cause it needs to be null in order to make suer that the database can auto-generate it
  final String time; //* Format: HH:mm (24-hour format)
  final List<int> days; //* Stores in android format (1 = Mon, ..., 7 = Sun)
  final bool enabled;

  Alarm({
    required this.id,
    required this.time,
    required this.days,
    required this.enabled,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'time': time,
        'days': days.join(','),
        'enabled': enabled ? 1 : 0,
      };

  @override
  String toString() =>
      'Alarm(id: $id, time: $time, days: $days, enabled: $enabled)';
}

// Makes the Alarm object
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