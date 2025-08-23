import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/more/view/repeat_selector.dart';
import 'package:uac_companion/app/utils/watch_shape_service.dart';
import '../controller/more_settings_controller.dart';
import '../../../utils/colors.dart';

class MoreSettingsView extends StatelessWidget {
  const MoreSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRound = WatchShapeService.isRound;

    final days = Get.arguments as List<int>? ?? [];
    // Initialize controller with actual days
    MoreSettingsController.to.init(days);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(
                  "Repeat on",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isRound ? 13 : 17,
                  ),
                ),
                subtitle: Obx(() => Text(
                      MoreSettingsController.to.selectedDaysText,
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
                onTap: () => showRepeatOptions(context),
              ),
            ),
            const Spacer(),
            Center(
              child: GestureDetector(
                onTap: () =>
                    Get.back(result: MoreSettingsController.to.selectedDays),
                child: Container(
                  padding: EdgeInsets.all(isRound ? 5 : 8),
                  decoration: BoxDecoration(
                    color: AppColors.green,
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
                  child: const Icon(
                    Icons.check,
                    size: 20,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}