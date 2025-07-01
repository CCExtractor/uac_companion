import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/routes/app_routes.dart';
import 'package:wear/wear.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/watch_shape_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        WatchShapeService.isRound = shape == WearShape.round;

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.home,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
