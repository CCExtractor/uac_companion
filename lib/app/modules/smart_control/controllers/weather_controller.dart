import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:uac_companion/app/modules/smart_control/views/weather/weather_condition_picker.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/smart_controls_controller.dart';

class WeatherConditionController extends GetxController {
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
      () => WeatherConditionPicker(selectedLabel: option['label']),
    );

    if (selectedWeatherCodes != null) {
      debugPrint(
        'Weather condition: ${option['label']} with codes $selectedWeatherCodes',
      );

      SmartControlsController.to.updateWeatherCondition(
        true,
        option['type'] as int,
        List<int>.from(selectedWeatherCodes),
      );
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
    final selectedWeatherCodes = selectedWeather.map((i) => i + 1).toList();
    debugPrint("Selected weather codes: $selectedWeatherCodes");
    Get.back(result: selectedWeatherCodes);
  }
}