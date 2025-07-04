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

  final RxInt selectedHour = 7.obs;
  final RxInt selectedMinute = 30.obs;
  final RxString selectedPeriod = 'AM'.obs;
  final RxInt selectedIconIndex = 1.obs;
  final RxList<int> selectedDays = <int>[].obs;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController periodController;

  int? initialHour;
  int? initialMinute;
  int? alarmId;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments ?? {};
    initialHour = args['initialHour'];
    initialMinute = args['initialMinute'];
    alarmId = args['alarmId'];

    final existingDays = args['existingDays'];
    // if (existingDays is List<int>) {
    //   selectedDays.assignAll(existingDays);
    // }
    if (existingDays is List<int>) {
      selectedDays.assignAll(androidToFlutterDays(existingDays));
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
    final hour24 = to24Hour(selectedHour.value, selectedPeriod.value);
    final formattedTime = formatTime(hour24, selectedMinute.value);
    final androidDays = flutterToAndroidDays(selectedDays);

    final alarm = Alarm(
      id: alarmId,
      time: formattedTime,
      days: androidDays,
      enabled: true,
    );

    debugPrint('flutter before insert/update: $alarm');

    final dbService = AlarmDBService();
    final finalAlarmId = alarmId != null
        ? await dbService.updateAlarm(alarm).then((_) => alarm.id!)
        : await dbService.insertAlarm(alarm);

    debugPrint("alarmID -> $finalAlarmId");
    await platform.invokeMethod('scheduleAlarm');
    Get.back(result: true);
  }

  void setHour(int hour) => selectedHour.value = hour;
  void setMinute(int minute) => selectedMinute.value = minute;
  void setPeriod(String period) => selectedPeriod.value = period;
  void setSelectedIcon(int index) => selectedIconIndex.value = index;
}
