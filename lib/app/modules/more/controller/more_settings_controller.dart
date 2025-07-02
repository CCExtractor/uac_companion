import 'package:get/get.dart';
import 'package:uac_companion/app/utils/days_utils.dart';

class MoreSettingsController extends GetxController {
  static MoreSettingsController get to => Get.find();

  var selectedDays = <int>[].obs;
  var selectedMode = ''.obs;

  void toggleDay(int index) {
    if (selectedMode.value != 'custom') return;
    selectedDays.contains(index)
        ? selectedDays.remove(index)
        : selectedDays.add(index);
  }

  String get selectedDaysText => getRepeatLabel(selectedMode.value, selectedDays);
}