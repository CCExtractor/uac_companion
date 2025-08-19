import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:uac_companion/app/data/alarm_model.dart';
import 'package:uac_companion/app/data/alarm_db_utils.dart';
import 'package:uac_companion/app/utils/days_utils.dart';
import 'package:uac_companion/app/utils/time_utils.dart';
import 'package:uac_companion/app/utils/unique_id_generator.dart';

class AlarmSetupControllers extends GetxController {
  static const platform = MethodChannel('uac_alarm_channel');
  static AlarmSetupControllers get to => Get.find();

  final RxInt selectedHour = 7.obs;
  final RxInt selectedMinute = 30.obs;
  final RxString selectedPeriod = 'AM'.obs;
  final RxInt selectedIconIndex = 1.obs;
  final RxList<int> selectedDays = <int>[].obs;

  final RxBool isActivityEnabled = false.obs;
  final RxInt activityInterval = 0.obs;
  final RxInt activityConditionType = 0.obs;

  final RxBool isGuardian = false.obs;
  final RxString guardian = ''.obs;
  final RxInt guardianTimer = 15.obs;
  final RxBool isCall = false.obs;

  final RxBool isWeatherEnabled = false.obs;
  final RxInt weatherConditionType = 0.obs;
  final RxList<int> weatherTypes = <int>[].obs;

  final RxBool isLocationEnabled = false.obs;
  final RxString location = ''.obs;
  final RxInt locationConditionType = 0.obs;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController periodController;

  int? initialHour;
  int? initialMinute;
  int? alarmId;

  void updateSmartControlsFromResult(Map<String, dynamic> result) {
    // Location
    isLocationEnabled.value = result['isLocationEnabled'] ?? false;
    locationConditionType.value = result['locationConditionType'] ?? 0;
    location.value = result['location'] ?? '';

    // Screen Activity
    isActivityEnabled.value = result['isActivityEnabled'] ?? false;
    activityConditionType.value = result['activityConditionType'] ?? 0;
    activityInterval.value = result['activityInterval'] ?? 0;

    // Weather
    isWeatherEnabled.value = result['isWeatherEnabled'] ?? false;
    weatherConditionType.value = result['weatherConditionType'] ?? 0;
    weatherTypes.assignAll(List<int>.from(result['weatherTypes'] ?? []));

    isGuardian.value = result['isGuardian'] ?? false;
    guardian.value = result['guardian'] ?? '';
    guardianTimer.value = result['guardianTimer'] ?? 15;
    isCall.value = result['isCall'] ?? false;

    debugPrint("Smart controls updated successfully in AlarmSetupController!");
  }

  void setGuardianData(
      bool enabled, String number, int timer, bool isCallSelected) {
    isGuardian.value = enabled;
    guardian.value = number;
    guardianTimer.value = timer;
    isCall.value = isCallSelected;
    debugPrint('AlarmSetup: Guardian Angel data updated.');
  }

  void setLocationData(bool enabled, int type, String selectedLocation) {
    isLocationEnabled.value = enabled;
    locationConditionType.value = type;
    location.value = selectedLocation;

    debugPrint('AlarmSetup: isLocationEnabled=$enabled, locaitonConditionType=$type, lcoationValue=$location');
  }

  void screenActivityData(bool enabled, int type, int time) {
    isActivityEnabled.value = enabled;
    activityConditionType.value = type;
    activityInterval.value = time;

    debugPrint('AlarmStup: isScrennActivityOn=$enabled, activityConditionType=$type, activityInterval=$time');
  }

  void setWeatherData(bool enabled, int type, List<int> weatherCodes) {
    isWeatherEnabled.value = enabled;
    weatherConditionType.value = type;
    weatherTypes.assignAll(weatherCodes);

    debugPrint(
      'AlarmSetup: WeatherType=$type, WeatherCodes=$weatherCodes, Enabled=$enabled',
    );
  }

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

    isLocationEnabled.value = args['isLocationEnabled'] ?? false;
    locationConditionType.value = args['locationConditionType'] ?? 0;
    location.value = args['location'] ?? '';

    isActivityEnabled.value = args['isActivityEnabled'] ?? false;
    activityConditionType.value = args['activityConditionType'] ?? 0;
    activityInterval.value = args['activityInterval'] ?? 0;

    isWeatherEnabled.value = args['isWeatherEnabled'] ?? false;
    weatherConditionType.value = args['weatherConditionType'] ?? 0;
    // Ensure weatherTypes is a List<int>
    if (args['weatherTypes'] is List) {
      weatherTypes.assignAll(List<int>.from(args['weatherTypes']));
    }

    isGuardian.value = args['isGuardian'] ?? false;
    guardian.value = args['guardian'] ?? '';
    guardianTimer.value = args['guardianTimer'] ?? 10;
    isCall.value = args['isCall'] ?? false;

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
    var uniqueIdGenerator = generateUniqueId();

    final alarm = Alarm(
      id: alarmId,
      time: formattedTime,
      days: androidDays,
      isEnabled: true,
      isOneTime: selectedDays.isEmpty ? 1 : 0,
      uniqueSyncId: uniqueIdGenerator,
      fromWatch: true,

      isLocationEnabled: isLocationEnabled.value,
      location: location.value,
      locationConditionType: locationConditionType.value,

      isActivityEnabled: isActivityEnabled.value,
      activityInterval: activityInterval.value,
      activityConditionType: activityConditionType.value,

      isWeatherEnabled: isWeatherEnabled.value,
      weatherConditionType: weatherConditionType.value,
      weatherTypes: weatherTypes.toList(),

      isGuardian: isGuardian.value,
      guardian: guardian.value,
      guardianTimer: guardianTimer.value,
      isCall: isCall.value,
    );

    debugPrint('flutter before insert/update: $alarm');
    final dbService = AlarmDBService();
    int finalAlarmId;
    int uniqueSyncId;

    if (alarmId != null) {
      await dbService.updateAlarm(alarm);
      finalAlarmId = alarm.id!;
      uniqueSyncId = finalAlarmId;
    } else {
      final insertedAlarm = await dbService.insertNewAlarm(alarm);
      finalAlarmId = insertedAlarm.id!;
      alarmId = finalAlarmId;
      uniqueSyncId = finalAlarmId;
    }

    await alarmChannel.invokeMethod('scheduleAlarm');

    final alarmMap = alarm.toMap();
    alarmMap['id'] = finalAlarmId;
    alarmMap['unique_sync_id'] = generateUniqueId();
    await syncChannel.invokeMethod('sendAlarmToPhone', alarmMap);

    Get.back(result: true);
  }

  void setHour(int hour) => selectedHour.value = hour;
  void setMinute(int minute) => selectedMinute.value = minute;
  void setPeriod(String period) => selectedPeriod.value = period;
  void setSelectedIcon(int index) => selectedIconIndex.value = index;
}