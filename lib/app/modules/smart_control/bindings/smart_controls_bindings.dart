import 'package:get/get.dart';
import 'package:uac_companion/app/modules/alarm_setup/controllers/alarm_setup_controllers.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/gaurdian_angel_controller.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/location_controller.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/screen_activity_controller.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/smart_controls_controller.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/weather_controller.dart';

class SmartControlBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SmartControlsController>(() => SmartControlsController());
    Get.lazyPut<LocationController>(() => LocationController());
    Get.lazyPut<ScreenActivityController>(() => ScreenActivityController());
    Get.lazyPut<WeatherConditionController>(() => WeatherConditionController());
    Get.lazyPut<GaurdianAngelController>(() => GaurdianAngelController());
    Get.lazyPut<AlarmSetupControllers>(() => AlarmSetupControllers());
  }
}