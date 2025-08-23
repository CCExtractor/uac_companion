import 'package:get/get.dart';
import 'package:uac_companion/app/modules/more/bindings/more_settings_bindings.dart';
import 'package:uac_companion/app/modules/smart_control/bindings/smart_controls_bindings.dart';
import 'package:uac_companion/app/modules/smart_control/views/gaurdian_angel/gaurdian_angel_view.dart';
import 'package:uac_companion/app/modules/smart_control/views/location/location_condition_view.dart';
import 'package:uac_companion/app/modules/smart_control/views/location/location_picker_view.dart';
import 'package:uac_companion/app/modules/smart_control/views/screen_activity/screen_activity_view.dart';
import 'package:uac_companion/app/modules/smart_control/views/screen_activity/screen_activity_timer.dart';
import 'package:uac_companion/app/modules/smart_control/views/smart_control_view.dart';
import 'package:uac_companion/app/modules/smart_control/views/weather/wather_condition_view.dart';
import 'package:uac_companion/app/modules/smart_control/views/weather/weather_condition_picker.dart';
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
    //! smart controls
    GetPage(
      name: AppRoutes.smartcontrol,
      page: () => const SmartControlsScreen(),
      binding: SmartControlBinding(),
    ),
    //! screen conditions
    GetPage(
      name: AppRoutes.screenActivity,
      page: () => ScreenActivity(),
      binding: SmartControlBinding(),
    ),
    GetPage(
      name: AppRoutes.screenActivityTimer,
      page: () => ScreenActivityTimer(),
      binding: SmartControlBinding(),
    ),
    //! weather conditions
    GetPage(
      name: AppRoutes.weatherCondition,
      page: () => const WeatherConditionScreen(),
      binding: SmartControlBinding(),
    ),
    GetPage(
      name: AppRoutes.weatherSelector,
      page: () => WeatherConditionPicker(),
      binding: SmartControlBinding(),
    ),
    //! location conditions
    GetPage(
      name: AppRoutes.locationConditionScreen,
      page: () => const LocationConditionScreen(),
      binding: SmartControlBinding(),
    ),
    GetPage(
      name: AppRoutes.locationPicker,
      page: () => const LocationPickerScreen(),
    ),
    //! gaurdian angel
    GetPage(
        name: AppRoutes.gaurdianAngelScreen,
        page: () => const GaurdianAngelScreen(),
        binding: SmartControlBinding(),
    ),
  ];
}