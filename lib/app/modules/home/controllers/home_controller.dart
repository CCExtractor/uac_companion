import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/alarm_data.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  var alarms = <Alarm>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAlarms();
  }

  Future<void> loadAlarms() async {
    final loadedAlarms = await AlarmDatabase.instance.getAlarms();
    alarms.assignAll(loadedAlarms);
  }

  //! Toggle Alarm Button
  Future<void> toggleAlarm(int index) async {
    final alarm = alarms[index];
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

        await const MethodChannel('alarm_channel').invokeMethod(
          'scheduleAlarm',
          {
            'alarmId': updatedAlarm.id,
            'hour': hour,
            'minute': minute,
          },
        );
      } else {
        await const MethodChannel('alarm_channel').invokeMethod(
          'cancelAlarm',
          {'id': updatedAlarm.id},
        );
      }
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
      //! Parse time string: "hh:mm AM/PM"
      final parts = alarm.time.split(RegExp(r'[: ]'));
      int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      final String amPm = parts[2];
      if (amPm == 'PM' && hour != 12) hour += 12;
      if (amPm == 'AM' && hour == 12) hour = 0;
      initialHour = hour;
      initialMinute = minute;
      alarmId = alarm.id;
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

      //! Update alarm
      if (id != null) {
        final updatedAlarm = Alarm(
          id: id,
          time: formattedTime,
          days: alarm?.days ?? 'Once',
          // enabled: alarm?.enabled ?? true,
          enabled: true,
        );
        await AlarmDatabase.instance.updateAlarm(updatedAlarm);

        // Reschedule updated alarm natively
        try {
          await const MethodChannel('alarm_channel').invokeMethod(
            'scheduleAlarm',
            {
              'alarmId': updatedAlarm.id,
              'hour': hour,
              'minute': minute,
            },
          );
        } catch (e) {
          debugPrint('Error rescheduling updated alarm: $e');
        }
      } else {
        //! Add new alarm and schedule it with the returned ID
        final insertedAlarm = await AlarmDatabase.instance.insertAlarm(
          Alarm(
            time: formattedTime,
            days: 'Once',
            enabled: true,
          ),
        );

        debugPrint(
            'New alarm inserted with ID=${insertedAlarm.id}, time=$formattedTime');

        // Extract hour and minute for native scheduling
        int scheduleHour = hour;
        int scheduleMinute = minute;

        try {
          await const MethodChannel('alarm_channel').invokeMethod(
            'scheduleAlarm',
            {
              'alarmId': insertedAlarm.id,
              'hour': scheduleHour,
              'minute': scheduleMinute,
            },
          );
        } catch (e) {
          debugPrint('Error scheduling new alarm: $e');
        }
      }

      await loadAlarms();
    }
  }

  //! Press & hold to delete alarm
  Future<void> deleteAlarm(Alarm alarm) async {
    debugPrint('Deleting alarm ID=${alarm.id}');
    if (alarm.id != null) {
      await AlarmDatabase.instance.deleteAlarm(alarm.id!);
    }

    alarms.removeWhere((a) => a.id == alarm.id); // Flutter list

    const platform = MethodChannel('alarm_channel');
    try {
      await platform.invokeMethod('cancelAlarm', {'id': alarm.id}); // Native
    } catch (e) {
      print('Alarm cancel failed: $e');
    }
  }
}
