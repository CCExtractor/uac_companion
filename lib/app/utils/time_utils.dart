// Converts 12-hour format with AM/PM to 24-hour format.
int to24Hour(int hour, String period) {
  if (period == 'AM') return hour == 12 ? 0 : hour;
  return hour == 12 ? 12 : hour + 12;
}

// Converts 24-hour to 12-hour with AM/PM.
Map<String, dynamic> to12Hour(int hour24) {
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
  return {'hour': hour, 'period': period};
}

// Returns "HH:mm" string from hour & minute.
String formatTime(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

// Parses "HH:mm" to hour & minute.
// Map<String, int> parseTime(String time) {
//   final parts = time.split(':');
//   return {
//     'hour': int.parse(parts[0]),
//     'minute': int.parse(parts[1]),
//   };
// }