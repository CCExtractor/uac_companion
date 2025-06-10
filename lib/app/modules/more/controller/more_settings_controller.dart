import 'package:get/get.dart';

class MoreSettingsController extends GetxController {
  var selectedDays = <int>[].obs;
  var selectedMode = ''.obs;

  void toggleDay(int index) {
    if (!selectedMode.value.contains('custom')) return;
    if (selectedDays.contains(index)) {
      selectedDays.remove(index);
    } else {
      selectedDays.add(index);
    }
  }

  /// Converts Flutter day index (0=Mon, ..., 6=Sun) to Android day (1=Sun, ..., 7=Sat) with wrap-around
  int flutterDayToAndroidDay(int day) {
    int androidDay = day + 2;
    if (androidDay > 7) androidDay -= 7;
    return androidDay;
  }

  String get selectedDaysText {
    if (selectedMode.value == 'weekdays') return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].join(', ');
    if (selectedMode.value == 'daily') return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].join(', ');
    if (selectedDays.isEmpty) return 'Once';
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return selectedDays.map((i) => days[i]).join(', ');
  }

  /// Returns Android days string (e.g. "2,3,4") to send to native side
  String get androidDaysString {
    if (selectedDays.isEmpty) return '';
    final androidDays = selectedDays.map(flutterDayToAndroidDay).toList();
    androidDays.sort();
    return androidDays.join(',');
  }
}