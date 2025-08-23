import 'package:get/get.dart';
import 'package:flutter/material.dart';

class GaurdianAngelController extends GetxController {
  static GaurdianAngelController get to => Get.find();

  var countryCode = "+91".obs;
  var phoneNumber = "".obs;
  var isCall = false.obs;

  void setPhoneNumber(String number) {
    phoneNumber.value = number;
  }
  void selectActionType(bool callSelected) {
    isCall.value = callSelected;
  }

  void confirm() {
    if (phoneNumber.value.trim().isEmpty) {
      Get.snackbar(
        "Input Required",
        "Please enter a valid phone number.",
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    final Map<String, dynamic> guardianData = {
      'isGuardian': true,
      'guardian': "${countryCode.value}${phoneNumber.value.trim()}",
      'guardianTimer': 10,
      'isCall': isCall.value,
    };

    Get.back(result: guardianData);
  }
}