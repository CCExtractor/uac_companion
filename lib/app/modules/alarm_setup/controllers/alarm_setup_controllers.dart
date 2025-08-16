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
    if (existingDays is List<int>) {
      selectedDays.assignAll(androidToFlutterDays(existingDays));
    }

    final hour24 = initialHour ?? DateTime.now().hour;
    final minute = initialMinute ?? DateTime.now().minute;
    final timeMap = to12Hour(hour24);

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
    const alarmChannel = MethodChannel('uac_alarm_channel');
    const syncChannel = MethodChannel('uac_alarm_sync');

    final alarm = Alarm(
      id: alarmId,
      time: formattedTime,
      days: androidDays,
      isEnabled: true,
      isOneTime: selectedDays.isEmpty ? 1 : 0,
      watchId: alarmId,
      fromWatch: true,
      // default values for unimplemented features
      isLocationEnabled: false,
      location: '',
      isGuardian: false,
      guardian: '',
      guardianTimer: 0,
      isCall: false,
    );

    debugPrint('flutter before insert/update: $alarm');
    final dbService = AlarmDBService();
    int finalAlarmId;
    int watchId;

    if (alarmId != null) {
      await dbService.updateAlarm(alarm);
      finalAlarmId = alarm.id!;
      watchId = finalAlarmId;
    } else {
      final insertedAlarm = await dbService.insertNewAlarm(alarm);
      finalAlarmId = insertedAlarm.id!;
      alarmId = finalAlarmId;
      watchId = finalAlarmId;
    }
    debugPrint("alarmID -> $finalAlarmId");
    debugPrint("watchId -> $watchId");
    //! Maybe need to send phonId in order to schedule the alarm for uniqueness
    await alarmChannel.invokeMethod('scheduleAlarm');

    final alarmMap = alarm.toMap();
    var offsetId = finalAlarmId + 100000;
    alarmMap['id'] = finalAlarmId;
    // alarmMap['phone_id'] = finalAlarmId.toString();
    alarmMap['watch_id'] = offsetId;
    await syncChannel.invokeMethod('sendAlarmToPhone', alarmMap);

    Get.back(result: true);
  }

  void setHour(int hour) => selectedHour.value = hour;
  void setMinute(int minute) => selectedMinute.value = minute;
  void setPeriod(String period) => selectedPeriod.value = period;
  void setSelectedIcon(int index) => selectedIconIndex.value = index;
}