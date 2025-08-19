import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/location_controller.dart';
import 'package:uac_companion/app/utils/colors.dart';
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selectedLatLng;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedLatLng = LocationController.defaultLatLng;
    _initMapPosition();
  }

  void _initMapPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapController.move(_selectedLatLng, 13);
      }
    });
  }

  void _onTapMap(tapPosition, latLng) {
    setState(() => _selectedLatLng = latLng);
  }

  void _confirmSelection() {
    debugPrint("Selected Lat: ${_selectedLatLng.latitude}, "
        "Lng: ${_selectedLatLng.longitude}");
    Get.back(result: _selectedLatLng);
  }

  @override
  Widget build(BuildContext context) {
    final isRound = WatchShapeService.isRound;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLatLng,
              initialZoom: 13,
              onTap: _onTapMap,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                // This header is important to comply with OpenStreetMap's policy.
                // headers: const {
                //   'User-Agent': 'com.ccextractor.uac_companion',
                // },
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLatLng,
                    width: 30,
                    height: 30,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 30, weight: 800,),
                  ),
                ],
              ),
            ],
          ),
         SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: _confirmSelection,
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