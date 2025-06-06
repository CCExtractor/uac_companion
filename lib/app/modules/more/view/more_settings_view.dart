import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../controller/more_settings_controller.dart';

class MoreSettingsView extends StatelessWidget {
  const MoreSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MoreSettingsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Repeat on",
                  style: TextStyle(color: AppColors.notSeleted)),
              subtitle: Obx(() => Text(
                    controller.selectedDaysText,
                    style:
                        const TextStyle(color: AppColors.green, fontSize: 12),
                  )),
              trailing: const Icon(Icons.arrow_forward_ios,
                  color: AppColors.green, size: 16),
              onTap: () => showRepeatOptions(context, controller),
            ),
          ],
        ),
      ),
    );
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
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  dense: true,
                  title: const Text("Weekdays",
                      style:
                          TextStyle(fontSize: 14, color: AppColors.notSeleted)),
                  onTap: () {
                    controller.selectedMode.value = 'weekdays';
                    controller.selectedDays.assignAll([0, 1, 2, 3, 4]);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  dense: true,
                  title: const Text("Daily",
                      style:
                          TextStyle(fontSize: 14, color: AppColors.notSeleted)),
                  onTap: () {
                    controller.selectedMode.value = 'daily';
                    controller.selectedDays.assignAll([0, 1, 2, 3, 4, 5, 6]);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  dense: true,
                  title: const Text("Custom",
                      style:
                          TextStyle(fontSize: 14, color: AppColors.notSeleted)),
                  onTap: () {
                    controller.selectedMode.value = 'custom';
                    controller.selectedDays
                        .clear(); // reset previous custom selections
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
                style: TextStyle(color: AppColors.green, fontSize: 16),
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
}
