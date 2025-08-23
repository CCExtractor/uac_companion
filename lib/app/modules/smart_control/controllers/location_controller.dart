import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/smart_controls_controller.dart';
import 'package:uac_companion/app/routes/app_routes.dart';

class LocationController extends GetxController {
  static LocationController get to => Get.find();

  final RxInt selectedIndex = (-1).obs;
  final List<Map<String, dynamic>> options = [
    {"label": "Ring at Location", "type": 1},
    {"label": "Cancel at Location", "type": 2},
    {"label": "Ring Away from Location", "type": 3},
    {"label": "Cancel Away from Location", "type": 4},
  ];

  //! need to change the defaultLatLng as user's current locaiton
  static final LatLng defaultLatLng = LatLng(28.6139, 77.2090);
  final MapController mapController = MapController();
  var pickerLatLng = defaultLatLng.obs;

  void onPickerScreenReady() {
    if (mapController.camera.center != pickerLatLng.value) {
      mapController.move(pickerLatLng.value, 13);
    }
  }

  Future<void> onSelectCondition(int index) async {
    pickerLatLng.value = defaultLatLng;

    final result = await Get.toNamed(AppRoutes.locationPicker);

    if (result is LatLng) {
      final selectedType = options[index]["type"] as int;
      //! check for location type on UAC
      final locationString ="${result.latitude},${result.longitude}";
      selectedIndex.value = index;

      SmartControlsController.to.updateLocationCondition(
        true,
        selectedType,
        locationString,
      );
      Get.back(result: true);
    }
  }

  void onTapMap(tapPosition, latLng) {
    pickerLatLng.value = latLng;
  }

  void confirmSelection() {
    Get.back(result: pickerLatLng.value);
  }
}