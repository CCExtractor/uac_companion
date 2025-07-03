import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uac_companion/app/data/alarm_model.dart';
import 'package:uac_companion/app/data/alarm_utils.dart';

//* needed widgetsBindingObserver to make sure that the alarms are loaded when the app is resumed
class HomeController extends GetxController with WidgetsBindingObserver {
  static HomeController get to => Get.find();
  var alarms = <Alarm>[].obs;
  static const platform = MethodChannel('uac_alarm_channel');
  final alarmService = AlarmDBService();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadAlarms();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadAlarms();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
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
      await platform.invokeMethod('scheduleAlarm');
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
      await platform.invokeMethod('scheduleAlarm');
      await loadAlarms();
    } catch (e) {
      debugPrint('Alarm delete/schedule failed: $e');
    }
  }
}
