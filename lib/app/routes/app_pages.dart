import 'package:get/get.dart';
import 'package:uac_companion/app/modules/more/bindings/more_settings_bindings.dart';
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
      name: AppRoutes.alarm_setup,
      page: () => const AlarmSetupView(),
      binding: AlarmSetupBinding(),
    ),

    GetPage(
      name: AppRoutes.more_settings,
      page: () => const MoreSettingsView(),
      binding: MoreSettingsBinding(),
    ),
  ];
}