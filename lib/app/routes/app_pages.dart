import 'package:get/get.dart';
import 'package:uac_companion/app/modules/more/bindings/more_settings_bindings.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/time_picker/views/time_picker_view.dart';
import '../modules/time_picker/bindings/time_picker_binding.dart';
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
      name: '/time_picker',
      page: () => const TimePickerView(),
      binding: TimePickerBinding(),
    ),

    GetPage(
      name: AppRoutes.more_settings,
      page: () => const MoreSettingsView(),
      binding: MoreSettingsBinding(),
    ),
  ];
}