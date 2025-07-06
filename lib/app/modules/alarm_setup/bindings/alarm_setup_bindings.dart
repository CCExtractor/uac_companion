import 'package:get/get.dart';
// import 'package:uac_companion/app/modules/more/controller/more_settings_controller.dart';
import '../controllers/alarm_setup_controllers.dart';

class AlarmSetupBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put<MoreSettingsController>(MoreSettingsController());
    Get.lazyPut<AlarmSetupControllers>(() => AlarmSetupControllers());
  }
}