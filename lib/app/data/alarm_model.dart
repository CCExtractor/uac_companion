class Alarm {
  // final int? id;
  int? id;
  final String time;
  final List<int> days;
  final bool isEnabled;
  final int isOneTime;
  final bool fromWatch;
  final bool isLocationEnabled;
  final String location;
  final bool isGuardian;
  final String guardian;
  final int guardianTimer;
  final bool isCall;
  //final bool isScreen
  //final int screenTime
  //final bool isWeather
  //final String weather
  
  Alarm({
    required this.id,
    required this.time,
    required this.days,
    required this.isEnabled,
    required this.isOneTime,
    required this.fromWatch,
    this.isLocationEnabled = false,
    this.location = '',
    this.isGuardian = false,
    this.guardian = '',
    this.guardianTimer = 0,
    this.isCall = false,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'time': time,
        'days': days.join(','),
        'is_enabled': isEnabled ? 1 : 0,
        'is_one_time': isOneTime,
        'from_watch': fromWatch ? 1 : 0,
        'is_location_enabled': isLocationEnabled ? 1 : 0,
        'location': location,
        'is_guardian': isGuardian ? 1 : 0,
        'guardian': guardian,
        'guardian_timer': guardianTimer,
        'is_call': isCall ? 1 : 0,
      };

  @override
  String toString() => 'Alarm(id: $id, time: $time, days: $days, isEnabled: $isEnabled, '
      'isOneTime: $isOneTime, fromWatch: $fromWatch ,isLocationEnabled: $isLocationEnabled, '
      'location: $location, isGuardian: $isGuardian, guardian: $guardian, '
      'guardianTimer: $guardianTimer, isCall: $isCall)';
}

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
    isEnabled: map['is_enabled'] == 1,
    isOneTime: map['is_one_time'] ?? 1,
    fromWatch: map['from_watch'] == 1,
    isLocationEnabled: (map['is_location_enabled'] ?? 0) == 1,
    location: map['location'] ?? '',
    isGuardian: (map['is_guardian'] ?? 0) == 1,
    guardian: map['guardian'] ?? '',
    guardianTimer: map['guardian_timer'] ?? 0,
    isCall: (map['is_call'] ?? 0) == 1,
  );
}