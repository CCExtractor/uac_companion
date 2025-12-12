import 'package:get/get.dart';

class MoreSettingsController extends GetxController {
  static MoreSettingsController get to => Get.find();

  RxList<int> selectedDays = <int>[].obs;
  RxString selectedMode = 'custom'.obs;
  RxInt snoozeDuration = 5.obs; // Default 5 minutes

  void init(List<int> days, {int snooze = 5}) {
    selectedDays.assignAll(days);
    snoozeDuration.value = snooze;

    if (matches([0, 1, 2, 3, 4])) {
      selectedMode.value = 'weekdays';
    } else if (matches([0, 1, 2, 3, 4, 5, 6])) {
      selectedMode.value = 'daily';
    } else {
      selectedMode.value = 'custom';
    }
  }

  void setSnoozeTime(int minutes) {
    snoozeDuration.value = minutes;
  }

  bool matches(List<int> preset) {
    if (selectedDays.length != preset.length) return false;
    return selectedDays.every(preset.contains);
  }

String get selectedDaysText {
  const map = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  if (selectedDays.length == 7) return 'Daily';
  if (matches([0, 1, 2, 3, 4])) return 'Weekdays';
  if (selectedDays.isEmpty) return 'One time';

  final sortedDays = [...selectedDays]..sort();
  return sortedDays.map((i) => map[i]).join(', ');
}

  void toggleDay(int day) {
    if (selectedDays.contains(day)) {
      selectedDays.remove(day);
    } else {
      selectedDays.add(day);
    }
  }
}
