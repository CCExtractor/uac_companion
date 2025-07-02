//* For UI we use 0-indexed days (0 = Monday, 6 = Sunday) and for storage and native we need 1-indexed.

//* to display the days in more_settings_view.dart
String getRepeatLabel(String mode, List<int> days) {
  if (mode == 'weekdays') return flutterDaysListToString([0, 1, 2, 3, 4]);
  if (mode == 'daily') return flutterDaysListToString([0, 1, 2, 3, 4, 5, 6]);
  return flutterDaysListToString(days);
}

// used for store in the DB (1-indexed days)
List<int> flutterToAndroidDays(List<int> flutterDays) {
  return flutterDays.map((d) => d + 1).toList();
}

// used for display in the UI (0-indexed days)
List<int> androidToFlutterDays(List<int> androidDays) {
  return androidDays.map((d) => d - 1).toList();
}

String flutterDaysListToString(List<int> days) {
  if (days.isEmpty) return 'Once';

  final daysSet = days.toSet();
  const allDays = {0, 1, 2, 3, 4, 5, 6};
  const weekdays = {0, 1, 2, 3, 4};
  const dayNames = {
    0: 'Mon',
    1: 'Tue',
    2: 'Wed',
    3: 'Thu',
    4: 'Fri',
    5: 'Sat',
    6: 'Sun',
  };

  if (daysSet.length == allDays.length) return 'Daily';
  if (daysSet.containsAll(weekdays) && daysSet.length == weekdays.length) {
    return 'Weekdays';
  }

  final sorted = days.toList()..sort();
  return sorted.map((d) => dayNames[d] ?? '?').join(', ');
}