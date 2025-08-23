import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/location_controller.dart';
import 'package:uac_companion/app/utils/colors.dart';
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class LocationPickerScreen extends StatelessWidget {
  const LocationPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRound = WatchShapeService.isRound;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: LocationController.to.mapController,
            options: MapOptions(
              initialCenter: LocationController.to.pickerLatLng.value,
              initialZoom: 13,
              onTap: LocationController.to.onTapMap,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              Obx(() => MarkerLayer(
                    markers: [
                      Marker(
                        point: LocationController.to.pickerLatLng.value,
                        width: 30,
                        height: 30,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 30, weight: 800),
                      ),
                    ],
                  )),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: LocationController.to.confirmSelection,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.grayBlack,
                    ),
                    padding: EdgeInsets.all(isRound ? 10 : 12),
                    child: const Icon(
                      Icons.check,
                      size: 28,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}