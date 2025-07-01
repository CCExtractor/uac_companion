// flutter days are 0-indexed (0 for Monday, 6 for Sunday), while Android days are 1-indexed (1 for Monday, 7 for Sunday).
String flutterDaysToAndroidDaysString(List<int> flutterDays) {
  return flutterDays.map((d) => d + 1).join(',');
}

// Needed to display the days in a user-friendly format.
String daysListToString(List<int> days) {
  if (days.isEmpty) return 'Once';

  final daysSet = days.toSet();
  const allDays = {0, 1, 2, 3, 4, 5, 6};
  const weekdays = {0, 1, 2, 3, 4};
  const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  if (daysSet.length == allDays.length) return 'Daily';
  if (daysSet.length == weekdays.length && daysSet.containsAll(weekdays)) {
    return 'Weekdays';
  }

  final sortedDays = days.toList()..sort();
  return sortedDays.map((d) => dayNames[d]).join(', ');
}
