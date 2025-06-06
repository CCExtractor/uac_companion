import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:uac_companion/app/modules/more/controller/more_settings_controller.dart';

class TimePickerController extends GetxController {
  static const platform = MethodChannel('alarm_channel');

  final int? initialHour;
  final int? initialMinute;
  final int? alarmId;

  var selectedHour = 7.obs;
  var selectedMinute = 30.obs;
  var selectedPeriod = 'AM'.obs;
  var selectedIconIndex = 1.obs;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController periodController;

  late MoreSettingsController moreSettingsController;

  TimePickerController({
    this.initialHour,
    this.initialMinute,
    this.alarmId,
  });

  @override
  void onInit() {
    super.onInit();
    moreSettingsController = Get.find<MoreSettingsController>();

    debugPrint(
        "TimePickerController initialized with alarmId=$alarmId, hour=$initialHour, minute=$initialMinute");

    final hour24 = initialHour ?? DateTime.now().hour;
    final minute = initialMinute ?? DateTime.now().minute;

    selectedHour.value = hour24 == 0
        ? 12
        : hour24 > 12
            ? hour24 - 12
            : hour24;
    selectedMinute.value = minute;
    selectedPeriod.value = hour24 >= 12 ? 'PM' : 'AM';

    hourController =
        FixedExtentScrollController(initialItem: selectedHour.value - 1);
    minuteController =
        FixedExtentScrollController(initialItem: selectedMinute.value);
    periodController = FixedExtentScrollController(
        initialItem: selectedPeriod.value == 'AM' ? 0 : 1);
  }

  //! We have gathered all the alarm data here and then send it back to the home_contoller and scheduled the alarm there.
  Future<void> confirmTime() async {
    int finalHour;
    if (selectedPeriod.value == 'AM') {
      finalHour = selectedHour.value == 12 ? 0 : selectedHour.value;
    } else {
      finalHour = selectedHour.value == 12 ? 12 : selectedHour.value + 12;
    }

    Get.back(result: {
      'hour': finalHour,
      'minute': selectedMinute.value,
      'alarmId': alarmId,
      'days': moreSettingsController.selectedDays,
    });
  }

  void setHour(int hour) {
    selectedHour.value = hour;
  }

  void setMinute(int minute) {
    selectedMinute.value = minute;
  }

  void setPeriod(String period) {
    selectedPeriod.value = period;
  }

  void setSelectedIcon(int index) {
    selectedIconIndex.value = index;
  }
}
