import 'package:get/get.dart';
import 'package:uac_companion/app/modules/more/controller/more_settings_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoreSettingsController>(() => MoreSettingsController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
