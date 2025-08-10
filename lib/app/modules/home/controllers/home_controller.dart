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

    const MethodChannel('uac_alarm_channel').setMethodCallHandler((call) async {
    if (call.method == 'onAlarmInserted') {
      debugPrint('Flutter: Received onAlarmInserted from native');
      await loadAlarms();
    }
  });
  }

  //* Needed for the WidgetsBindingObserver to listen to app lifecycle changes
  // Used to refresh the alarm list after the alarm notification is triggered
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

  Future<void> toggleAlarm(int id) async {
  final updatedAlarms = alarms.map((alarm) {
    if (alarm.id == id) {
      final updated = Alarm(
        id: alarm.id,
        time: alarm.time,
        days: alarm.days,
        isEnabled: !alarm.isEnabled,
        isOneTime: alarm.isOneTime,
        fromWatch: alarm.fromWatch,
        isLocationEnabled: false,
        location: '',
        isGuardian: false,
        guardian: '',
        guardianTimer: 0,
        isCall: false,
      );
      return updated;
    }
    return alarm;
  }).toList();

  final updatedAlarm = updatedAlarms.firstWhere((a) => a.id == id);
  alarms.assignAll(updatedAlarms);
  await alarmService.updateAlarm(updatedAlarm);
  debugPrint('HomeController -> Alarm toggled: $updatedAlarm');

  try {
    if (!updatedAlarm.isEnabled) {
      await platform.invokeMethod('cancelAlarm', {
        'id': updatedAlarm.id,
        'days': updatedAlarm.days,
      });
    }
    await platform.invokeMethod('scheduleAlarm');
    await loadAlarms();
  } catch (e) {
    debugPrint('HomeController -> Error toggling alarm: $e');
  }
}

  // Future<void> deleteAlarm(Alarm alarm) async {
  //   if (alarm.id == null) return;

  //   await alarmService.deleteAlarm(alarm.id!);
  //   alarms.removeWhere((a) => a.id == alarm.id);

  //   try {
  //     await platform.invokeMethod('scheduleAlarm');
  //     // const syncChannel = MethodChannel('uac_alarm_sync');
  //     debugPrint('HomeController -> Alarm with ID ${alarm.id} deleted and scheduled for cancellation');
  //     await loadAlarms();
  //   } catch (e) {
  //     debugPrint('HomeControlelr -> Alarm delete/schedule failed: $e');
  //   }
  // }
  Future<void> deleteAlarm(Alarm alarm) async {
  if (alarm.id == null) return;
  try {
    await platform.invokeMethod('cancelAlarm', {
      'id': alarm.id,
    });
    await alarmService.deleteAlarm(alarm.id!);
    alarms.removeWhere((a) => a.id == alarm.id);
    await platform.invokeMethod('scheduleAlarm');
    await loadAlarms();
  } catch (e) {
    debugPrint('HomeController -> Alarm delete/cancel failed: $e');
  }
}
}