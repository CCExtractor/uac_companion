import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_routes.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/watch_shape_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        WatchShapeService.init(context);
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          // initialRoute: AppRoutes.home,
          initialRoute: AppRoutes.locationPicker,
          getPages: AppPages.routes,
        );
      },
    );
  }
}