import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uac_companion/app/modules/smart_control/views/weather/weather_condition_picker.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/smart_controls_controller.dart';

class WeatherConditionController extends GetxController {
  // Add this static getter to easily access the controller instance
  static WeatherConditionController get to => Get.find();

  final List<Map<String, dynamic>> options = [
    {'label': 'Ring when Match', 'icon': Icons.alarm, 'type': 1},
    {'label': 'Cancel when Match', 'icon': Icons.alarm_off, 'type': 2},
    {'label': 'Ring when Different', 'icon': Icons.alarm_on, 'type': 3},
    {'label': 'Cancel when Different', 'icon': Icons.cancel, 'type': 4},
  ];

  var selectedIndex = (-1).obs;
  var selectedWeather = <int>{}.obs;
  final centerIndex = 0.obs;

  final List<String> weatherOptions = [
    "Sunny",
    "Cloudy",
    "Rainy",
    "Windy",
    "Stormy",
  ];

  Future<void> selectOption(int index) async {
    selectedIndex.value = index;
    final option = options[index];
    debugPrint('Selected weather option: ${option['label']}');

    final selectedWeatherCodes = await Get.to(
      () => WeatherConditionPicker(), // Pass the label via arguments
      arguments: option['label'],
    );

    if (selectedWeatherCodes != null && selectedWeatherCodes is List<int>) {
      debugPrint(
        'Weather condition: ${option['label']} with codes $selectedWeatherCodes',
      );

      SmartControlsController.to.updateWeatherCondition(
        true,
        option['type'] as int,
        selectedWeatherCodes,
      );
      // Let the SmartControlsController handle Get.back() if needed
    }
  }

  void toggleWeather(int index) {
    if (selectedWeather.contains(index)) {
      selectedWeather.remove(index);
    } else {
      selectedWeather.add(index);
    }
  }

  void confirmSelection() {
    // The weather codes are 1-based, so map the 0-based index
    final selectedWeatherCodes = selectedWeather.map((index) => index).toList();
    debugPrint("Selected weather codes: $selectedWeatherCodes");
    Get.back(result: selectedWeatherCodes);
  }
}