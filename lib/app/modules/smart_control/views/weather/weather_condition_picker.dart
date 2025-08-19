import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/weather_controller.dart';
import 'package:uac_companion/app/utils/colors.dart' as uac_colors;
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class WeatherConditionPicker extends StatelessWidget {
  final String selectedLabel;
  final WeatherConditionController controller = Get.find();

  WeatherConditionPicker({super.key, required this.selectedLabel});

  @override
  Widget build(BuildContext context) {
    final isRound = WatchShapeService.isRound;

    return Scaffold(
      backgroundColor: uac_colors.AppColors.background,
      body: SafeArea(
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
                SizedBox(height: isRound ? 3 : 5),
                Text(
                  'Select Weather Condition',
                  style: TextStyle(
                    fontSize: isRound ? 12 : 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isRound ? 5 : 8),
                _buildWeatherPicker(isRound),
                SizedBox(height: isRound ? 5 : 10),
                GestureDetector(
                  onTap: controller.confirmSelection,
                  child: Container(
                    padding: EdgeInsets.all(isRound ? 8 : 10),
                    decoration: const BoxDecoration(
                      color: uac_colors.AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: isRound ? 22 : 26,
                      color: uac_colors.AppColors.background,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherPicker(bool isRound) {
    return SizedBox(
      height: isRound ? 95 : 110,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        decoration: BoxDecoration(
          color: uac_colors.AppColors.grayBlack,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Obx(() => ListWheelScrollView.useDelegate(
              itemExtent: 35,
              diameterRatio: 1.4,
              physics: const FixedExtentScrollPhysics(),
              perspective: 0.002,
              onSelectedItemChanged: (index) =>
                  controller.centerIndex.value = index,
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List.generate(
                  controller.weatherOptions.length,
                  (index) {
                    final isSelected =
                        controller.selectedWeather.contains(index);
                    return GestureDetector(
                      onTap: () => controller.toggleWeather(index),
                      child: Center(
                        child: Text(
                          controller.weatherOptions[index],
                          style: TextStyle(
                            fontSize: isSelected ? 24 : 20,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? uac_colors.AppColors.green
                                : Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )),
      ),
    );
  }
}