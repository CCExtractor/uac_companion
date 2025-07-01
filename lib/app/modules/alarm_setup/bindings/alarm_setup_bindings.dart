import 'package:get/get.dart';
import 'package:uac_companion/app/modules/more/controller/more_settings_controller.dart';
import '../controllers/alarm_setup_controllers.dart';

// class TimePickerBinding extends Bindings {
//   @override
//   void dependencies() {
//     final args = Get.arguments ?? {};
//     Get.lazyPut<MoreSettingsController>(() => MoreSettingsController());
//     Get.lazyPut<TimePickerController>(() => TimePickerController(
//       //dont pass here do this in contoller
//       initialHour: args['initialHour'],
//       initialMinute: args['initialMinute'],
//       alarmId: args['alarmId'],
//     ));
//   }
// }

class AlarmSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MoreSettingsController>(MoreSettingsController());
    // Get.lazyPut<MoreSettingsController>(() => MoreSettingsController());
    Get.lazyPut<AlarmSetupControllers>(() => AlarmSetupControllers());
  }
}