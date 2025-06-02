// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/routes/app_routes.dart';
import 'package:wear/wear.dart';
import 'app/routes/app_pages.dart';
import './watch_shape.dart';

void main() {
  // Register DeviceController only once globally before any UI
  Get.put(DeviceController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        final bool isRound = shape == WearShape.round;

        // Only fetch, don't recreate
        final deviceController = Get.find<DeviceController>();
        deviceController.setShape(isRound);

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.home,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
