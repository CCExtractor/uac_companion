import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uac_companion/app/data/alarm_model.dart';
import 'package:uac_companion/app/data/alarm_db_utils.dart';

//* needed widgetsBindingObserver to make sure that the alarms are loaded when the app is resumed
class HomeController extends GetxController with WidgetsBindingObserver {
  static HomeController get to => Get.find();
  static const MethodChannel watchChannel = MethodChannel('uac_alarm_sync');
  var alarms = <Alarm>[].obs;
  static const platform = MethodChannel('uac_alarm_channel');
  final alarmService = AlarmDBService();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadAlarms();

    //! if native receives alarm from phone then reload the UI
    const MethodChannel('uac_alarm_channel').setMethodCallHandler((call) async {
      if (call.method == 'alarmsChanged') {
        debugPrint(
            'Flutter (Watch): Received alarmsChanged event. Reloading alarms.');
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

  Future<void> toggleAlarm(String uniqueSyncId) async {
    final updatedAlarms = alarms.map((alarm) {
      if (alarm.uniqueSyncId == uniqueSyncId) {
        final updated = Alarm(
          id: alarm.id,
          time: alarm.time,
          days: alarm.days,
          isEnabled: !alarm.isEnabled,
          isOneTime: alarm.isOneTime,
          fromWatch: alarm.fromWatch,
          uniqueSyncId: alarm.uniqueSyncId,
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

    final updatedAlarm =
        updatedAlarms.firstWhere((a) => a.uniqueSyncId == uniqueSyncId);
    alarms.assignAll(updatedAlarms);
    await alarmService.updateAlarm(updatedAlarm);
    debugPrint('HomeController -> Alarm toggled: $updatedAlarm');

    try {
      if (!updatedAlarm.isEnabled) {
        await platform.invokeMethod('cancelAlarm', {
          'id': updatedAlarm.id,
          'uniqueSyncId': updatedAlarm.uniqueSyncId,
        });
      }
      await platform.invokeMethod('scheduleAlarm');
      final alarmMap = updatedAlarm.toMap();
      alarmMap['isNewAlarm'] = false;

      await watchChannel.invokeMethod('sendAlarmToPhone', alarmMap);
      await loadAlarms();
    } catch (e) {
      debugPrint('HomeController -> Error toggling alarm: $e');
    }
  }

  Future<void> deleteAlarm(Alarm alarm) async {
    if (alarm.uniqueSyncId == null) return;
    try {
      await platform.invokeMethod(
          'cancelAlarm', {'id': alarm.id, 'uniqueSyncId': alarm.uniqueSyncId});
      await alarmService.deleteAlarm(alarm.uniqueSyncId!);
      alarms.removeWhere((a) => a.uniqueSyncId == alarm.uniqueSyncId);
      await platform.invokeMethod('scheduleAlarm');
      await loadAlarms();
      await watchChannel.invokeMethod('sendActionToPhone', {
        'action': "delete alarm",
        'uniqueSyncId': alarm.uniqueSyncId,
        // 'id': alarm.id
      });
    } catch (e) {
      debugPrint('HomeController -> Alarm delete/cancel failed: $e');
    }
  }
}