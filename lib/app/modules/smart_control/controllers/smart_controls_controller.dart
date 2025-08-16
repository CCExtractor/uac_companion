import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/routes/app_routes.dart';

class SmartControlsController extends GetxController {
  var isScreenActivityOn = false.obs;
  var isGuardianAngelOn = false.obs;
  var isWeatherConditionOn = false.obs;
  var isLocationConditionOn = false.obs;

  void toggleScreenActivity(bool value) {
    isScreenActivityOn.value = value;
    debugPrint("toggleScreenActivity -> $value");
    if (value == true) {
      Get.toNamed(AppRoutes.screenActivity);
    }
  }

  void toggleWeatherCondition(bool value) {
    isWeatherConditionOn.value = value;
    debugPrint("toggleWeatherCondition -> $value");
    if (value == true) {
      Get.toNamed(AppRoutes.weatherCondition);
    }
  }

  void toggleGuardianAngel(bool value) {
    isGuardianAngelOn.value = value;
    debugPrint("toggleGuardianAngel -> $value");
  }


  void toggleLocationBased(bool value) {
    isLocationConditionOn.value = value;
    debugPrint("toggleLocationBased -> $value");
  }
}
