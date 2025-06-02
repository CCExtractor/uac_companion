import 'package:get/get.dart';

class DeviceController extends GetxController {
  final RxBool isRound = false.obs;

void setShape(bool value) {
  isRound.value = value;
}

}
