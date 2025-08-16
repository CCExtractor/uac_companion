import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  var selectedPosition = const LatLng(0, 0).obs;
  GoogleMapController? mapController;

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void onTap(LatLng position) {
    selectedPosition.value = position;
    // log for now
    print("Selected Location: ${position.latitude}, ${position.longitude}");
  }
}
