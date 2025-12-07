import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/smart_controls_controller.dart';
import 'package:uac_companion/app/routes/app_routes.dart';
import 'package:fl_location/fl_location.dart';
import 'package:flutter/material.dart';

class LocationController extends GetxController {
  static LocationController get to => Get.find();

  final RxInt selectedIndex = (-1).obs;
  final List<Map<String, dynamic>> options = [
    {"label": "Ring at Location", "type": 1},
    {"label": "Cancel at Location", "type": 2},
    {"label": "Ring Away from Location", "type": 3},
    {"label": "Cancel Away from Location", "type": 4},
  ];

  static final LatLng fallbackLatLng = LatLng(28.6139, 77.2090); // New Delhi as fallback
  final MapController mapController = MapController();
  late Rx<LatLng> pickerLatLng;

  @override
  void onInit() {
    super.onInit();
    pickerLatLng = fallbackLatLng.obs;
  }

  void onPickerScreenReady() {
    if (mapController.camera.center != pickerLatLng.value) {
      mapController.move(pickerLatLng.value, 13);
    }
  }

  Future<void> onSelectCondition(int index) async {
    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final location = await _determinePosition();
      if (location != null) {
        pickerLatLng.value = LatLng(location.latitude, location.longitude);
      } else {
        pickerLatLng.value = fallbackLatLng;
        Get.snackbar("Location Unavailable", "Using default location.", 
          snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      pickerLatLng.value = fallbackLatLng;
      Get.snackbar("Location Error", "Could not fetch location: $e. Using default.",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      // Close loading
      if (Get.isDialogOpen == true) Get.back();
    }
    
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

  Future<Location?> _determinePosition() async {
    if (!await FlLocation.isLocationServicesEnabled) {
      Get.snackbar("Location Disabled", "Please enable location services.",
          snackPosition: SnackPosition.BOTTOM);
      return null;
    }

    var locationPermission = await FlLocation.checkLocationPermission();
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await FlLocation.requestLocationPermission();
      if (locationPermission == LocationPermission.denied) {
        Get.snackbar("Permission Denied", "Location permission is required.",
            snackPosition: SnackPosition.BOTTOM);
        return null;
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      Get.snackbar("Permission Denied", "Location permission is permanently denied. Please enable it in settings.",
          snackPosition: SnackPosition.BOTTOM);
      return null;
    }

    try {
      return await FlLocation.getLocation(
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }
}