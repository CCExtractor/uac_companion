import 'package:get/get.dart';
import '../controller/more_settings_controller.dart';

class MoreSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoreSettingsController>(() => MoreSettingsController());
  }
}