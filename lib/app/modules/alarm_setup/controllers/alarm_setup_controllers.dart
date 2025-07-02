import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:uac_companion/app/data/alarm_model.dart';
import 'package:uac_companion/app/data/alarm_utils.dart';
import 'package:uac_companion/app/utils/days_utils.dart';
import 'package:uac_companion/app/utils/time_utils.dart';

class AlarmSetupControllers extends GetxController {
  static const platform = MethodChannel('uac_alarm_channel');
  static AlarmSetupControllers get to => Get.find();

  int? initialHour;
  int? initialMinute;
  int? alarmId;

  final selectedHour = 7.obs;
  final selectedMinute = 30.obs;
  final selectedPeriod = 'AM'.obs;
  final selectedIconIndex = 1.obs;

  final RxList<int> selectedDays = <int>[].obs;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController periodController;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};
    initialHour = args['initialHour'];
    initialMinute = args['initialMinute'];
    alarmId = args['alarmId'];

    final existingDays = args['existingDays'];
    if (existingDays != null && existingDays is List<int>) {
      selectedDays.assignAll(existingDays);
    }

    final hour24 = initialHour ?? DateTime.now().hour;
    final minute = initialMinute ?? DateTime.now().minute;
    final timeMap = from24Hour(hour24);

    selectedHour.value = timeMap['hour'];
    selectedPeriod.value = timeMap['period'];
    selectedMinute.value = minute;

    hourController =
        FixedExtentScrollController(initialItem: selectedHour.value - 1);
    minuteController =
        FixedExtentScrollController(initialItem: selectedMinute.value);
    periodController = FixedExtentScrollController(
        initialItem: selectedPeriod.value == 'AM' ? 0 : 1);
  }

  Future<void> confirmTime() async {
    final finalHour = to24Hour(selectedHour.value, selectedPeriod.value);
    final formattedTime = formatTime(finalHour, selectedMinute.value);
    final androidDays = flutterToAndroidDays(selectedDays);

    final alarm = Alarm(
      id: alarmId,
      time: formattedTime,
      // days: selectedDays,
      days: androidDays,
      enabled: true,
    );

    debugPrint('flutter before updation/insertion: $alarm');

    final dbService = AlarmDBService();
    final finalAlarm = alarmId != null
        ? await dbService.updateAlarm(alarm).then((_) => alarm)
        : await dbService.insertAlarm(alarm);

    await platform.invokeMethod('scheduleAlarm', {
      'alarmId': finalAlarm.id,
      'hour': finalHour,
      'minute': selectedMinute.value,
      'days': androidDays,
    });

    Get.back(result: true);
  }

  void setHour(int hour) => selectedHour.value = hour;
  void setMinute(int minute) => selectedMinute.value = minute;
  void setPeriod(String period) => selectedPeriod.value = period;
  void setSelectedIcon(int index) => selectedIconIndex.value = index;
}
