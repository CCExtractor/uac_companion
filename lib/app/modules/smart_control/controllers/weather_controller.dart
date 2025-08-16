import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

enum WeatherConditionType { sunny, cloudy, rainy, windy, stormy }

class WeatherPickerController extends GetxController {
  final selectedIndexes = <int>{}.obs;
  final weatherOptions = [
    "Sunny",
    "Cloudy",
    "Rainy",
    "Windy",
    "Stormy",
  ];

  void toggleWeather(int index) {
    if (selectedIndexes.contains(index)) {
      selectedIndexes.remove(index);
    } else {
      selectedIndexes.add(index);
    }
  }

  String getSelectedWeatherString() {
    if (selectedIndexes.isEmpty) return '';
    final sorted = selectedIndexes.toList()..sort();
    return sorted.map((i) => weatherOptions[i]).join(', ');
  }
}