import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uac_companion/app/data/alarm_model.dart';
import 'package:uac_companion/app/data/alarm_utils.dart';
import '../../../utils/time_utils.dart';
import '../../../utils/days_utils.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();
  var alarms = <Alarm>[].obs;
  static const platform = MethodChannel('uac_alarm_channel');
  final alarmService = AlarmDBService();

  @override
  void onInit() {
    super.onInit();
    loadAlarms();
  }

  Future<void> loadAlarms() async {
    final loadedAlarms = await alarmService.getAlarms();
    alarms.assignAll(loadedAlarms);
  }

  Future<void> toggleAlarm(int index) async {
    final alarm = alarms[index];
    final updatedAlarm = Alarm(
      id: alarm.id,
      time: alarm.time,
      days: alarm.days,
      enabled: !alarm.enabled,
    );

    alarms[index] = updatedAlarm;
    await alarmService.updateAlarm(updatedAlarm);

    try {
      if (updatedAlarm.enabled) {
        final time = parseTime(updatedAlarm.time);
        final androidDays = flutterToAndroidDays(updatedAlarm.days);
        await platform.invokeMethod('scheduleAlarm', {
          'alarmId': updatedAlarm.id,
          'hour': time['hour'],
          'minute': time['minute'],
          'days': androidDays,
        });
      } else {
        await platform.invokeMethod('cancelAlarm', {'id': alarm.id});
      }
      await loadAlarms();
    } catch (e) {
      debugPrint('Error toggling alarm: $e');
    }
  }

//! Currently used in the home_view.dart but doubtfull.....
  // Future<void> navigateToTimePicker(BuildContext context, {Alarm? alarm}) async {
  //   final result = await Get.toNamed('/time_picker', arguments: {
  //     'initialHour': alarm != null ? parseTime(alarm.time)['hour'] : null,
  //     'initialMinute': alarm != null ? parseTime(alarm.time)['minute'] : null,
  //     'alarmId': alarm?.id,
  //     'existingDays': alarm?.days,
  //   });

  //   if (result == true) {
  //     await loadAlarms();
  //   }
  // }

  Future<void> deleteAlarm(Alarm alarm) async {
    if (alarm.id == null) return;

    await alarmService.deleteAlarm(alarm.id!);
    alarms.removeWhere((a) => a.id == alarm.id);

    try {
      await platform.invokeMethod('cancelAlarm', {'id': alarm.id});
      await loadAlarms();
    } catch (e) {
      debugPrint('Alarm cancel failed: $e');
    }
  }
}
