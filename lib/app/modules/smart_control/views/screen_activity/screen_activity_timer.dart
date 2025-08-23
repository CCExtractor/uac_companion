import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/screen_activity_controller.dart';
import 'package:uac_companion/app/utils/colors.dart' as uac_colors;
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class ScreenActivityTimer extends StatelessWidget {
  final String selectedLabel = Get.arguments as String? ?? 'Select Duration';

  ScreenActivityTimer({super.key});

  @override
  Widget build(BuildContext context) {
    final isRound = WatchShapeService.isRound;

    return Scaffold(
      backgroundColor: uac_colors.AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: isRound ? 20 : 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedLabel,
                    style: TextStyle(
                      fontSize: isRound ? 12 : 14,
                      fontWeight: FontWeight.w500,
                      color: uac_colors.AppColors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Select time duration',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isRound ? 5 : 8),
                  _buildMinutePicker(isRound),
                  SizedBox(height: isRound ? 5 : 10),
                  _buildIconButton(
                    Icons.check,
                    ScreenActivityController.to.confirmTimer,
                    true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinutePicker(bool isRound) {
    return Container(
      decoration: BoxDecoration(
        color: uac_colors.AppColors.grayBlack,
        borderRadius: BorderRadius.circular(50),
      ),
      child: SizedBox(
        height: isRound ? 90 : 100,
        width: isRound ? 150 : 155,
        child: Obx(
          () => ListWheelScrollView.useDelegate(
            controller: FixedExtentScrollController(
              initialItem: ScreenActivityController.to.selectedMinutes.value - 1,
            ),
            itemExtent: 36,
            perspective: 0.005,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) => ScreenActivityController.to.setMinutes(index + 1),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List.generate(60, (index) {
                final int minuteValue = index + 1;
                final bool isSelected = ScreenActivityController.to.selectedMinutes.value == minuteValue;
                return Center(
                  child: Text(
                    minuteValue.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: isSelected ? (isRound ? 25 : 30) : 20,
                      color: isSelected
                          ? uac_colors.AppColors.green
                          : Colors.grey.shade600,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, bool isSelected) {
    final isRound = WatchShapeService.isRound;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isRound ? 5 : 8),
        decoration: BoxDecoration(
          color: isSelected
              ? uac_colors.AppColors.green
              : uac_colors.AppColors.grayBlack,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: isRound ? 20 : 24,
          color: isSelected ? uac_colors.AppColors.background : const Color(0xB3FFFFFF),
        ),
      ),
    );
  }
}