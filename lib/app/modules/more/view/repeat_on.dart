import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/utils/watch_shape_service.dart';
import '../../../utils/colors.dart';
import '../controller/more_settings_controller.dart';

class RepeatSelectorTile extends StatelessWidget {
  final MoreSettingsController controller;
  const RepeatSelectorTile({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // final isRound = Get.find<DeviceController>().isRound.value;
    final isRound = WatchShapeService.isRound;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          "Repeat on",
          style: TextStyle(
            color: Colors.white,
            fontSize: isRound ? 13 : 17,
          ),
        ),
        subtitle: Obx(() => Text(
              controller.selectedDaysText,
              style: TextStyle(
                color: AppColors.green,
                fontSize: isRound ? 10 : 12,
              ),
            )),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.green,
          size: 16,
        ),
        onTap: () => showRepeatOptions(context, controller),
      ),
    );
  }
}

void showRepeatOptions(
    BuildContext context, MoreSettingsController controller) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      // final isRound = Get.find<DeviceController>().isRound.value;
      final isRound = WatchShapeService.isRound;
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: isRound ? 1 : 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                title: Center(
                  child: Text(
                    "Weekdays",
                    style: TextStyle(
                      fontSize: isRound ? 14 : 16,
                      color: AppColors.notSeleted,
                    ),
                  ),
                ),
                onTap: () {
                  controller.selectedMode.value = 'weekdays';
                  controller.selectedDays.assignAll([0, 1, 2, 3, 4]);
                  //getx 
                  Navigator.pop(context);
                },
              ),
              ListTile(
                dense: true,
                title: Center(
                  child: Text(
                    "Daily",
                    style: TextStyle(
                      fontSize: isRound ? 14 : 16,
                      color: AppColors.notSeleted,
                    ),
                  ),
                ),
                onTap: () {
                  controller.selectedMode.value = 'daily';
                  controller.selectedDays.assignAll([0, 1, 2, 3, 4, 5, 6]);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                dense: true,
                title: Center(
                  child: Text(
                    "Custom",
                    style: TextStyle(
                      fontSize: isRound ? 14 : 16,
                      color: AppColors.notSeleted,
                    ),
                  ),
                ),
                onTap: () {
                  controller.selectedMode.value = 'custom';
                  controller.selectedDays.clear();
                  Navigator.pop(context);
                  showCustomDayPicker(context, controller);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showCustomDayPicker(
    BuildContext context, MoreSettingsController controller) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.grayBlack,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Container(
        padding: const EdgeInsets.only(top: 10),
        height: 250,
        child: Column(
          children: [
            const Text(
              "Select Days",
              style: TextStyle(color: AppColors.notSeleted, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() => ListWheelScrollView.useDelegate(
                    itemExtent: 40,
                    diameterRatio: 1.5,
                    physics: const FixedExtentScrollPhysics(),
                    perspective: 0.002,
                    childDelegate: ListWheelChildLoopingListDelegate(
                      children: List.generate(days.length, (index) {
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
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.green,
              ),
              child: const Text("Confirm"),
            ),
          ],
        ),
      );
    },
  );
}
