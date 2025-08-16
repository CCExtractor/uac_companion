class Alarm {
  int? id; // local DB primary key
  final int? watchId;
  final String time;
  final List<int> days;
  final bool isEnabled;
  final int isOneTime;
  final bool fromWatch;

  // Screen Activity
  final bool isActivityEnabled;
  final int activityInterval;
  final int activityConditionType;

  // Guardian Angel
  final bool isGuardian;
  final String guardian;
  final int guardianTimer;
  final bool isCall;

  // Weather Condition
  final bool isWeatherEnabled;
  final int weatherConditionType;
  final List<int> weatherTypes;

  // Location Condition
  final bool isLocationEnabled;
  final String location;
  final int locationConditionType;

  Alarm({
    this.id,
    this.watchId,
    required this.time,
    required this.days,
    required this.isEnabled,
    required this.isOneTime,
    required this.fromWatch,
    this.isActivityEnabled = false,
    this.activityInterval = 0,
    this.activityConditionType = 0,
    this.isGuardian = false,
    this.guardian = '',
    this.guardianTimer = 0,
    this.isCall = false,
    this.isWeatherEnabled = false,
    this.weatherConditionType = 0,
    this.weatherTypes = const [],
    this.isLocationEnabled = false,
    this.location = '',
    this.locationConditionType = 0,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'watch_id': watchId,
        'time': time,
        'days': days.join(','),
        'is_enabled': isEnabled ? 1 : 0,
        'is_one_time': isOneTime,
        'from_watch': fromWatch ? 1 : 0,

        // Screen Activity
        'is_activity_enabled': isActivityEnabled ? 1 : 0,
        'activity_interval': activityInterval,
        'activity_condition_type': activityConditionType,

        // Guardian Angel
        'is_guardian': isGuardian ? 1 : 0,
        'guardian': guardian,
        'guardian_timer': guardianTimer,
        'is_call': isCall ? 1 : 0,

        // Weather Condition
        'is_weather_enabled': isWeatherEnabled ? 1 : 0,
        'weather_condition_type': weatherConditionType,
        'weather_types': weatherTypes.join(','),

        // Location Condition
        'is_location_enabled': isLocationEnabled ? 1 : 0,
        'location': location,
        'location_condition_type': locationConditionType,
      };

  @override
  String toString() => 'Alarm(id: $id, watchId: $watchId, time: $time, days: $days, '
      'isEnabled: $isEnabled, isOneTime: $isOneTime, fromWatch: $fromWatch, '
      'isActivityEnabled: $isActivityEnabled, activityInterval: $activityInterval, activityConditionType: $activityConditionType, '
      'isGuardian: $isGuardian, guardian: $guardian, guardianTimer: $guardianTimer, isCall: $isCall, '
      'isWeatherEnabled: $isWeatherEnabled, weatherConditionType: $weatherConditionType, weatherTypes: $weatherTypes, '
      'isLocationEnabled: $isLocationEnabled, location: $location, locationConditionType: $locationConditionType)';
}

Alarm alarmFromMap(Map<String, dynamic> map) {
  final rawDays = map['days'];
  final parsedDays = (rawDays is String && rawDays.isNotEmpty)
      ? rawDays
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList()
      : <int>[];

  final rawWeatherTypes = map['weather_types'];
  final parsedWeatherTypes = (rawWeatherTypes is String && rawWeatherTypes.isNotEmpty)
      ? rawWeatherTypes
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList()
      : <int>[];

  return Alarm(
    id: map['id'],
    // phoneId: map['phone_id'] ?? null, // fallback to '' if missing for old rows
    watchId: map['watch_id'],
    time: map['time'],
    days: parsedDays,
    isEnabled: (map['is_enabled'] ?? 0) == 1,
    isOneTime: map['is_one_time'] ?? 1,
    fromWatch: (map['from_watch'] ?? 0) == 1,

    // Screen Activity
    isActivityEnabled: (map['is_activity_enabled'] ?? 0) == 1,
    activityInterval: map['activity_interval'] ?? 0,
    activityConditionType: map['activity_condition_type'] ?? 0,

    // Guardian Angel
    isGuardian: (map['is_guardian'] ?? 0) == 1,
    guardian: map['guardian'] ?? '',
    guardianTimer: map['guardian_timer'] ?? 0,
    isCall: (map['is_call'] ?? 0) == 1,

    // Weather Condition
    isWeatherEnabled: (map['is_weather_enabled'] ?? 0) == 1,
    weatherConditionType: map['weather_condition_type'] ?? 0,
    weatherTypes: parsedWeatherTypes,

    // Location Condition
    isLocationEnabled: (map['is_location_enabled'] ?? 0) == 1,
    location: map['location'] ?? '',
    locationConditionType: map['location_condition_type'] ?? 0,
  );
}