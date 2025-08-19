import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/location_controller.dart';
import 'package:uac_companion/app/utils/colors.dart' as uac_colors;
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class LocationConditionScreen extends StatelessWidget {
  final LocationController controller = Get.put(LocationController());

  LocationConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isRound = WatchShapeService.isRound;

    return Scaffold(
      backgroundColor: uac_colors.AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: isRound ? 10 : 8),
            Text(
              'Location Condition',
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
                itemCount: controller.options.length,
                itemBuilder: (context, i) {
                  final option = controller.options[i];
                  
                  return Obx(() {
                    final isSelected = controller.selectedIndex.value == i;
                    return _buildConditionButton(
                      label: option['label'],
                      type: option['type'],
                      index: i,
                      isRound: isRound,
                      isSelected: isSelected,
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionButton({
    required String label,
    required int type,
    required int index,
    required bool isRound,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.onSelect(index),
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
              _getLocationConditionIcon(type),
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
                  color:
                      isSelected ? uac_colors.AppColors.green : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getLocationConditionIcon(int type) {
    switch (type) {
      case 1:
        return Icons.location_on; // Ring at Location
      case 2:
        return Icons.location_disabled; // Cancel at Location
      case 3:
        return Icons.directions_walk; // Ring Away
      case 4:
        return Icons.not_listed_location; // Cancel Away
      default:
        return Icons.place_outlined;
    }
  }
}