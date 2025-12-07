import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoreSettingsController extends GetxController {
  static MoreSettingsController get to => Get.find();

  RxList<int> selectedDays = <int>[].obs;
  RxString selectedMode = 'custom'.obs;
  RxInt snoozeDuration = 5.obs; // Default 5 minutes

  @override
  void onInit() {
    super.onInit();
    _loadSnoozeTime();
  }

  Future<void> _loadSnoozeTime() async {
    final prefs = await SharedPreferences.getInstance();
    snoozeDuration.value = prefs.getInt('snooze_duration') ?? 5;
  }

  Future<void> setSnoozeTime(int minutes) async {
    snoozeDuration.value = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('snooze_duration', minutes);
  }

  void init(List<int> days) {
    selectedDays.assignAll(days);

    if (matches([0, 1, 2, 3, 4])) {
      selectedMode.value = 'weekdays';
    } else if (matches([0, 1, 2, 3, 4, 5, 6])) {
      selectedMode.value = 'daily';
    } else {
      selectedMode.value = 'custom';
    }
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
