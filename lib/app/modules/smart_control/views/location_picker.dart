import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/location_controller.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LocationController());

    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: Obx(() => GoogleMap(
            onMapCreated: controller.onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(28.6139, 77.2090), // Default: Delhi
              zoom: 14,
            ),
            onTap: controller.onTap,
            markers: {
              Marker(
                markerId: const MarkerId("selected"),
                position: controller.selectedPosition.value,
              ),
            },
          )),
    );
  }
}
