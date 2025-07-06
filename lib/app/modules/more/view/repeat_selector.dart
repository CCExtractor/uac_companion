import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/more/controller/daysListMatcher.dart';
import 'package:uac_companion/app/utils/colors.dart';
import 'package:uac_companion/app/utils/watch_shape_service.dart';
import '../controller/more_settings_controller.dart';

class RepeatSelectorTile extends StatelessWidget {
  const RepeatSelectorTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isRound = WatchShapeService.isRound;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          "Repeat on",
          style: TextStyle(color: Colors.white, fontSize: isRound ? 13 : 17),
        ),
        subtitle: Obx(() => Text(
              MoreSettingsController.to.selectedDaysText,
              style: TextStyle(
                  color: AppColors.green, fontSize: isRound ? 10 : 12),
            )),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: AppColors.green, size: 16),
        onTap: () => showRepeatOptions(context),
      ),
    );
  }
}

void showRepeatOptions(BuildContext context) {
  final controller = MoreSettingsController.to;
  final isRound = WatchShapeService.isRound;

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: isRound ? 1 : 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _option("Weekdays", () {
              controller.selectedMode.value = 'weekdays';
              controller.selectedDays.assignAll([0, 1, 2, 3, 4]);
            }),
            _option("Daily", () {
              controller.selectedMode.value = 'daily';
              controller.selectedDays.assignAll([0, 1, 2, 3, 4, 5, 6]);
            }),
            _option("Custom", () {
              controller.selectedMode.value = 'custom';
              controller.selectedDays.clear();
              // Delay picker opening until after this sheet is closed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showCustomDayPicker(context);
              });
            }),
          ],
        ),
      ),
    ),
  );
}

Widget _option(String label, VoidCallback onTap) {
  final controller = MoreSettingsController.to;
  final isRound = WatchShapeService.isRound;

  // Define preset selections
  final presetDays = {
    "Weekdays": [0, 1, 2, 3, 4],
    "Daily": [0, 1, 2, 3, 4, 5, 6],
  };

  final currentDays = controller.selectedDays;
  final matchDays = presetDays[label];

  bool isSelected;

  if (label == "Custom") {
    // Custom = Not Weekdays, Not Daily
    final isWeekdays = DaysListMatcher.matches(currentDays, presetDays["Weekdays"]!);
    final isDaily = DaysListMatcher.matches(currentDays, presetDays["Daily"]!);
    isSelected = !isWeekdays && !isDaily;
  } else {
    isSelected = matchDays != null &&
        currentDays.length == matchDays.length &&
        currentDays.every((d) => matchDays.contains(d));
  }

  return ListTile(
    dense: true,
    title: Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: isRound ? 14 : 16,
          color: isSelected ? AppColors.green : AppColors.notSeleted,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
    onTap: () {
      onTap();
      Get.back();
    },
  );
}

void _showCustomDayPicker(BuildContext context) {
  final controller = MoreSettingsController.to;
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.grayBlack,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Container(
      padding: const EdgeInsets.only(top: 10),
      height: 250,
      child: Column(
        children: [
          const Text("Select Days",
              style: TextStyle(color: AppColors.notSeleted, fontSize: 12)),
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() => ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.002,
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: List.generate(7, (index) {
                      final isSelected =
                          controller.selectedDays.contains(index);
                      return GestureDetector(
                        onTap: () => controller.toggleDay(index),
                        child: Center(
                          child: Text(
                            days[index],
                            style: TextStyle(
                              fontSize: isSelected ? 22 : 18,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.green
                                  : AppColors.notSeleted,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                )),
          ),
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: AppColors.green),
            child: const Text("Confirm"),
          ),
        ],
      ),
    ),
  );
}