import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/screen_activity_controller.dart';
import 'package:uac_companion/app/utils/colors.dart' as uac_colors;
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class ScreenActivity extends StatelessWidget {
  const ScreenActivity({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.put(ScreenActivityController());
    final isRound = WatchShapeService.isRound;

    return Scaffold(
      backgroundColor: uac_colors.AppColors.background,
      body: Column(
        children: [
          SizedBox(height: isRound ? 10 : 8),
          Text(
            'Screen Activity',
            style: TextStyle(
              fontSize: isRound ? 12 : 14,
              fontWeight: FontWeight.normal,
              color: uac_colors.AppColors.green,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: isRound ? 6 : 8,
                bottom: isRound ? 40 : 8,
                left: isRound ? 10 : 14,
                right: isRound ? 10 : 14,
              ),
              itemCount: ScreenActivityController.to.options.length,
              itemBuilder: (context, i) {
                final option = ScreenActivityController.to.options[i];

                return Obx(() {
                  final isSelected = ScreenActivityController.to.selectedIndex.value == i;
                  return _buildActivityButton(
                    option['label'],
                    option['type'],
                    i,
                    isRound,
                    isSelected,
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityButton(
    String label,
    int type,
    int index,
    bool isRound,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => ScreenActivityController.to.handleOptionSelection(index),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: isRound ? 4 : 6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? uac_colors.AppColors.green.withOpacity(0.2)
              : uac_colors.AppColors.grayBlack,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment:
              isRound ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              _getActivityConditionIcon(type),
              size: isRound ? 16 : 18,
              color: isSelected ? uac_colors.AppColors.green : Colors.white,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize:
                      isSelected ? (isRound ? 13 : 15) : (isRound ? 12 : 14),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? uac_colors.AppColors.green : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityConditionIcon(int conditionType) {
    switch (conditionType) {
      case 1: return Icons.smartphone;
      case 2: return Icons.phone_android;
      case 3: return Icons.mobile_off;
      case 4: return Icons.do_not_disturb_on;
      default: return Icons.help_outline;
    }
  }
}