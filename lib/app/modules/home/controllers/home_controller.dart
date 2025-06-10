import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/more/controller/more_settings_controller.dart';
import '../../../data/alarm_data.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  var alarms = <Alarm>[].obs;
  late MoreSettingsController moreSettingsController;

  static const platform = MethodChannel('alarm_channel');

  @override
  void onInit() {
    super.onInit();
    moreSettingsController = Get.find<MoreSettingsController>();
    loadAlarms();
  }

  Future<void> loadAlarms() async {
    final loadedAlarms = await AlarmDatabase.instance.getAlarms();
    debugPrint('Loaded ${loadedAlarms.length} alarms from database');
    alarms.assignAll(loadedAlarms);
  }

  //! Toggle Alarm Button
  Future<void> toggleAlarm(int index) async {
    final alarm = alarms[index];
    if (alarm.id == null) {
      debugPrint('Alarm ID is null, cannot toggle');
      return;
    }

    final updatedAlarm = Alarm(
      id: alarm.id,
      time: alarm.time,
      days: alarm.days,
      enabled: !alarm.enabled,
    );
    debugPrint(
        'Toggling alarm ID=${alarm.id}, index=$index, enabled=${updatedAlarm.enabled}');

    alarms[index] = updatedAlarm;
    await AlarmDatabase.instance.updateAlarm(updatedAlarm);

    try {
      if (updatedAlarm.enabled) {
        // Parse hour and minute from time string "hh:mm AM/PM"
        final parts = updatedAlarm.time.split(RegExp(r'[: ]'));
        int hour = int.parse(parts[0]);
        final int minute = int.parse(parts[1]);
        final String amPm = parts[2];
        if (amPm == 'PM' && hour != 12) hour += 12;
        if (amPm == 'AM' && hour == 12) hour = 0;

        final String androidDaysString = flutterDaysToAndroidDaysString(updatedAlarm.days);
        await platform.invokeMethod(
          'scheduleAlarm',
          {
            'alarmId': updatedAlarm.id,
            'hour': hour,
            'minute': minute,
            'days': androidDaysString,
          },
        );
      } else {
        await platform.invokeMethod(
          'cancelAlarm',
          {'id': alarm.id!},
        );
      }
      await loadAlarms();
    } catch (e) {
      debugPrint('Error toggling alarm: $e');
    }
  }

  //! Navigate to Time Picker
  Future<void> navigateToTimePicker(BuildContext context,
      {Alarm? alarm}) async {
    int? initialHour;
    int? initialMinute;
    int? alarmId;

    if (alarm != null) {
      // Convert Android days (1-7) to Flutter days (0-6)
      List<int> daysList = alarm.days;

      moreSettingsController.selectedDays.assignAll(daysList);

      // Parse time string: "hh:mm AM/PM"
      final parts = alarm.time.split(RegExp(r'[: ]'));
      int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      final String amPm = parts[2];
      if (amPm == 'PM' && hour != 12) hour += 12;
      if (amPm == 'AM' && hour == 12) hour = 0;
      initialHour = hour;
      initialMinute = minute;
      alarmId = alarm.id;
    } else {
      moreSettingsController.selectedDays.clear();
    }

    final result = await Navigator.pushNamed(
      context,
      '/time_picker',
      arguments: {
        'initialHour': initialHour,
        'initialMinute': initialMinute,
        'alarmId': alarmId,
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      final int hour = result['hour'];
      final int minute = result['minute'];
      final int? id = result['alarmId'];

      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final formattedTime =
          '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';

      // Use selectedDays from controller
      final flutterDays = moreSettingsController.selectedDays;
      final String androidDaysString =
          flutterDaysToAndroidDaysString(flutterDays);

      if (id != null) {
        //! UPDATE existing alarm
        final updatedAlarm = Alarm(
          id: id,
          time: formattedTime,
          days: flutterDays, //List<int>
          enabled: true,
        );
        await AlarmDatabase.instance.updateAlarm(updatedAlarm);
        await platform.invokeMethod(
          'scheduleAlarm',
          {
            'alarmId': updatedAlarm.id!,
            'hour': hour,
            'minute': minute,
            'days': androidDaysString,
          },
        );
      } else {
        //! INSERT new alarm
        final insertedAlarm = await AlarmDatabase.instance.insertAlarm(
          Alarm(
            time: formattedTime,
            days: flutterDays,
            enabled: true,
          ),
        );
        await platform.invokeMethod(
          'scheduleAlarm',
          {
            'alarmId': insertedAlarm.id!,
            'hour': hour,
            'minute': minute,
            'days': androidDaysString,
          },
        );
      }
      await loadAlarms();
    }
  }

  String flutterDaysToAndroidDaysString(List<int> flutterDays) {
    // Android days are 1-based (Mon=1,...Sun=7)
    List<int> androidDays = flutterDays.map((d) => d + 1).toList();
    return androidDays.join(',');
  }

  //! Press & hold to delete alarm
  Future<void> deleteAlarm(Alarm alarm) async {
    debugPrint('Deleting alarm ID=${alarm.id}');
    if (alarm.id == null) {
      debugPrint('Alarm ID is null, cannot delete');
      return;
    }

    await AlarmDatabase.instance.deleteAlarm(alarm.id!);
    alarms.removeWhere((a) => a.id == alarm.id);

    try {
      await platform.invokeMethod(
        'cancelAlarm',
        {'id': alarm.id!},
      );
      await loadAlarms();
    } catch (e) {
      debugPrint('Alarm cancel failed: $e');
    }
  }
}
