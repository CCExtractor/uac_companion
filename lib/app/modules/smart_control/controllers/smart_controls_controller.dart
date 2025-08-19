import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/alarm_setup/controllers/alarm_setup_controllers.dart';
import 'package:uac_companion/app/routes/app_routes.dart';

class SmartControlsController extends GetxController {
  static SmartControlsController get to => Get.find();

  var isScreenActivityOn = false.obs;
  var isWeatherConditionOn = false.obs;
  var isLocationEnabled = false.obs;
  var isGuardian = false.obs;

  final RxInt locationConditionType = 0.obs;
  final RxString location = ''.obs;

  final RxInt activityConditionType = 0.obs;
  final RxInt activityInterval = 0.obs;

  var weatherConditionType = 0.obs;
  final RxList<int> weatherTypes = <int>[].obs;

  final RxString guardian = ''.obs;
  final RxInt guardianTimer = 15.obs;
  final RxBool isCall = false.obs;

  @override
  void onInit() {
    super.onInit();
    final initialSettings = Get.arguments as Map<String, dynamic>? ?? {};

    isWeatherConditionOn.value = initialSettings['isWeatherEnabled'] ?? false;
    isLocationEnabled.value = initialSettings['isLocationEnabled'] ?? false;
    isScreenActivityOn.value = initialSettings['isActivityEnabled'] ?? false;
    isGuardian.value = initialSettings['isGuardian'] ?? false;

    weatherConditionType.value = initialSettings['weatherConditionType'] ?? 0;
    if (initialSettings['weatherTypes'] is List) {
      weatherTypes.assignAll(List<int>.from(initialSettings['weatherTypes']));
    }

    locationConditionType.value = initialSettings['locationConditionType'] ?? 0;
    location.value = initialSettings['location'] ?? '';

    activityConditionType.value = initialSettings['activityConditionType'] ?? 0;
    activityInterval.value = initialSettings['activityInterval'] ?? 0;

    guardian.value = initialSettings['guardian'] ?? '';
    guardianTimer.value = initialSettings['guardianTimer'] ?? 15;
    isCall.value = initialSettings['isCall'] ?? false;
  }

  //! ScreenActivity
  void toggleScreenActivity(bool value) async {
    if (value) {
      final result = await Get.toNamed(AppRoutes.screenActivity);
     if (result == true) {
        isScreenActivityOn.value = true;
      }
    } else {
      isScreenActivityOn.value = false;
      updateScreenActivityCondition(false, 0, 0);
    }
  }
  void updateScreenActivityCondition(bool enabled, int type, int minutes) {
    AlarmSetupControllers.to.screenActivityData(enabled, type, minutes);
  }

  //! weather Coniditon
  void toggleWeatherCondition(bool value) async {
    if (value) {
      final result = await Get.toNamed(AppRoutes.weatherCondition);
      if (result == true) {
        isWeatherConditionOn.value = true;
      }
    } else {
      isWeatherConditionOn.value = false;
    }
  }

  void updateWeatherCondition(bool enabled, int type, List<int> weatherCodes) {
    AlarmSetupControllers.to.setWeatherData(enabled, type, weatherCodes,);
  }

  //! Guardian Angel
  void toggleGuardianAngel(bool value) async {
    if (value) {
      final result = await Get.toNamed(AppRoutes.gaurdianAngelScreen);
      if (result != null && result is Map<String, dynamic>) {
        isGuardian.value = true;
        updateGuardianAngel(true, result);
      }
    } else {
      isGuardian.value = false;
      updateGuardianAngel(false, {});
    }
  }
  void updateGuardianAngel(bool enabled, Map<String, dynamic> data) {
    guardian.value = data['guardian'] ?? '';
    guardianTimer.value = data['guardianTimer'] ?? 15;
    isCall.value = data['isCall'] ?? false;

    AlarmSetupControllers.to.setGuardianData(
      enabled,
      guardian.value,
      guardianTimer.value,
      isCall.value,
    );
  }

  //! Location Conditions
  void toggleLocationBased(bool value) async {
    if (value) {
      final result = await Get.toNamed(AppRoutes.locationConditionScreen);
      if (result == true) {
        isLocationEnabled.value = true;
      }
    } else {
      isLocationEnabled.value = false;
      updateLocationCondition(false, 0, '');
    }
  }
  void updateLocationCondition(bool enabled, int type, String selectedLocation) {
    AlarmSetupControllers.to.setLocationData(enabled, type, selectedLocation);
  }
}
