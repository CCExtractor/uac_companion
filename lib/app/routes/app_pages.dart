import 'package:get/get.dart';
import 'package:uac_companion/app/modules/more/bindings/more_settings_bindings.dart';
import 'package:uac_companion/app/modules/smart_control/views/location_picker.dart';
import 'package:uac_companion/app/modules/smart_control/views/screen_activity.dart';
import 'package:uac_companion/app/modules/smart_control/views/screen_activity_timer.dart';
import 'package:uac_companion/app/modules/smart_control/views/smart_control.dart';
import 'package:uac_companion/app/modules/smart_control/views/wather_condition.dart';
import 'package:uac_companion/app/modules/smart_control/views/weather_condition_picker.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/alarm_setup/views/alarm_setup_view.dart';
import '../modules/alarm_setup/bindings/alarm_setup_bindings.dart';
import '../modules/more/view/more_settings_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.alarmSetup,
      page: () => const AlarmSetupView(),
      binding: AlarmSetupBinding(),
    ),
    GetPage(
      name: AppRoutes.moreSettings,
      page: () => const MoreSettingsView(),
      binding: MoreSettingsBinding(),
    ),
    GetPage(
      name:  AppRoutes.smartcontrol,
      page: () => const SmartControlsScreen(),
    ),
    GetPage(
      name:  AppRoutes.screenActivity,
      page: () => const ScreenActivity(),
    ),
    GetPage(
      name:  AppRoutes.screenActivityTimer,
      page: () => const ScreenActivityTimer(selectedLabel: '',),
    ),
    GetPage(
      name:  AppRoutes.weatherCondition,
      page: () => const WeatherConditionScreen(),
    ),
    GetPage(
      name:  AppRoutes.weatherSelector,
      page: () => const Weather_condition_picker(selectedLabel: '',),
    ),
    GetPage(
      name: AppRoutes.locationPicker,
      page: () => LocationPicker(),    
    ),
  ];
}