import 'package:get/get.dart';
import '../controllers/time_picker_controller.dart';

class TimePickerBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments ?? {};
    Get.lazyPut<TimePickerController>(() => TimePickerController(
      initialHour: args['initialHour'],
      initialMinute: args['initialMinute'],
      alarmId: args['alarmId'],
    ));
  }
}
