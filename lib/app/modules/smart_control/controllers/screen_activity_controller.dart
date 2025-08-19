import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/smart_controls_controller.dart';
import 'package:uac_companion/app/routes/app_routes.dart';

class ScreenActivityController extends GetxController {
  var selectedIndex = (-1).obs;
  var selectedMinutes = 1.obs;

  final List<Map<String, dynamic>> options = [
    {'label': 'Ring when Active', 'type': 1},
    {'label': 'Cancel when Active', 'type': 2},
    {'label': 'Ring when Inactive', 'type': 3},
    {'label': 'Cancel when Inactive', 'type': 4},
  ];

  @override
  void onInit() {
    super.onInit();
    setMinutes(selectedMinutes.value);
  }

  void selectOption(int index) {
    selectedIndex.value = index;
    debugPrint('Selected option: ${options[index]['label']}');
  }

  void setMinutes(int minutes) {
    selectedMinutes.value = minutes;
    debugPrint('Selected duration: $minutes minutes');
  }

  Future<void> handleOptionSelection(int index) async {
    selectOption(index);
    final String label = options[index]['label'];

    final result = await Get.toNamed(
      AppRoutes.screenActivityTimer,
      arguments: label,
    );

    if (result != null && result is int) {
      final smartController = Get.find<SmartControlsController>();
      final selectedType = options[index]['type'] as int;

      smartController.updateScreenActivityCondition(true, selectedType, result);
      Get.back(result: true);
    } else {
      selectedIndex.value = -1;
    }
  }
}