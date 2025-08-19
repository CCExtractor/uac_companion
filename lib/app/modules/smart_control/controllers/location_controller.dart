import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/smart_controls_controller.dart';
import 'package:uac_companion/app/routes/app_routes.dart';

class LocationController extends GetxController {
  static LocationController get to => Get.find();
  static final LatLng defaultLatLng = LatLng(28.6139, 77.2090);

  final RxInt selectedIndex = (-1).obs;
  final RxString selectedLocation = ''.obs;

  final List<Map<String, dynamic>> options = [
    {"label": "Ring at Location", "type": 1},
    {"label": "Cancel at Location", "type": 2},
    {"label": "Ring Away from Location", "type": 3},
    {"label": "Cancel Away from Location", "type": 4},
  ];

  Future<void> onSelect(int index) async {
    final result = await Get.toNamed(AppRoutes.locationPicker);

    if (result is LatLng) {
      final selectedType = options[index]["type"] as int;
      final locationString = "${result.latitude}, ${result.longitude}";
      selectedIndex.value = index;
      selectedLocation.value = locationString;
      
      SmartControlsController.to.updateLocationCondition(
        true,
        selectedType,
        locationString,
      );
      Get.back(result: true);
    }
  }
}