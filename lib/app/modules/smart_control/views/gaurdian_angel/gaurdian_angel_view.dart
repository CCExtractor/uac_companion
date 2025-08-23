import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/gaurdian_angel_controller.dart';
import 'package:uac_companion/app/utils/colors.dart' as uac_colors;
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class GaurdianAngelScreen extends StatelessWidget {
  const GaurdianAngelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.put(GaurdianAngelController()); 
    
    final isRound = WatchShapeService.isRound;

    return Scaffold(
      backgroundColor: uac_colors.AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: isRound ? 18 : 15),
            Text(
              "Enter Angel's Number",
              style: TextStyle(
                fontSize: isRound ? 12 : 14,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            SizedBox(height: isRound ? 3 : 10),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isRound ? 16 : 12,
                  vertical: isRound ? 10 : 8,
                ),
                child: Column(
                  children: [
                    _buildPhoneNumberInput(isRound),
                    SizedBox(height: isRound ? 5 : 12),
                    _buildActionButtons(isRound),
                    SizedBox(height: isRound ? 5 : 12),
                    _buildConfirmButton(isRound),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneNumberInput(bool isRound) {
    return Container(
      width: isRound ? 150 : 170,
      decoration: BoxDecoration(
        color: uac_colors.AppColors.grayBlack,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
      child: Row(
        children: [
          Obx(
            () => Text(
              // Use the static accessor here
              GaurdianAngelController.to.countryCode.value,
              style: TextStyle(
                fontSize: isRound ? 12 : 14,
                fontWeight: FontWeight.normal,
                color: uac_colors.AppColors.green,
              ),
            ),
          ),
          SizedBox(width: isRound ? 5 : 6),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: isRound ? 12 : 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Phone Number",
                hintStyle: TextStyle(color: Colors.grey, fontSize: isRound ? 12 : 14),
              ),
              keyboardType: TextInputType.phone,
              // Use the static accessor here
              onChanged: GaurdianAngelController.to.setPhoneNumber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isRound) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionButton(
            icon: Icons.message,
            // Use the static accessor here
            isSelected: !GaurdianAngelController.to.isCall.value,
            onTap: () => GaurdianAngelController.to.selectActionType(false),
          ),
          SizedBox(width: isRound ? 25 : 28),
          _actionButton(
            icon: Icons.phone,
            // Use the static accessor here
            isSelected: GaurdianAngelController.to.isCall.value,
            onTap: () => GaurdianAngelController.to.selectActionType(true),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(bool isRound) {
    return GestureDetector(
      // Use the static accessor here
      onTap: GaurdianAngelController.to.confirm,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: uac_colors.AppColors.grayBlack,
        ),
        padding: EdgeInsets.all(isRound ? 7 : 12),
        child: const Icon(
          Icons.check,
          size: 24,
          color: uac_colors.AppColors.green,
        ),
      ),
    );
  }
  
  Widget _actionButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isRound = WatchShapeService.isRound;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isRound ? 12 : 8),
          color: isSelected ? uac_colors.AppColors.green : uac_colors.AppColors.grayBlack,
        ),
        padding: EdgeInsets.all(isRound ? 9 : 11),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}