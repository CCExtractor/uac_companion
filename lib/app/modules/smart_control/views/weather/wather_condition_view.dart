import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/weather_controller.dart';
import 'package:uac_companion/app/utils/colors.dart' as uac_colors;
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class WeatherConditionScreen extends StatelessWidget {
  const WeatherConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller for this feature
    Get.put(WeatherConditionController());
    final isRound = WatchShapeService.isRound;

    return Scaffold(
      backgroundColor: uac_colors.AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: isRound ? 12 : 10),
            Text(
              'Weather Condition',
              style: TextStyle(
                fontSize: isRound ? 12 : 15,
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
                itemCount: WeatherConditionController.to.options.length,
                itemBuilder: (context, i) {
                  final opt = WeatherConditionController.to.options[i];
                  return Obx(() => _buildWeatherButton(
                        opt['label'],
                        opt['icon'],
                        i,
                        isRound,
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherButton(
    String label,
    IconData icon,
    int index,
    bool isRound,
  ) {
    final bool isSelected = WeatherConditionController.to.selectedIndex.value == index;

    return GestureDetector(
      onTap: () => WeatherConditionController.to.selectOption(index),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: isRound ? 4 : 6),
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: isRound ? 12 : 12,
        ),
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
              icon,
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
}