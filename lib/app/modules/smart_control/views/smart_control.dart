import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/smart_control/controllers/smart_controls_controller.dart';
import 'package:uac_companion/app/utils/colors.dart';
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class SmartControlsScreen extends StatelessWidget {
  const SmartControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SmartControlsController());
    final isRound = WatchShapeService.isRound;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.all(isRound ? deviceWidth * 0.08 : 12),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Smart Controls',
                  style: TextStyle(
                    fontSize: isRound ? 12 : 15,
                    color: AppColors.green,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Obx(() => buildControlItem(
                      title: 'Screen Activity',
                      showSwitch: true,
                      switchValue: controller.isScreenActivityOn.value,
                      onSwitchChanged: controller.toggleScreenActivity,
                      isRound: isRound,
                    )),
                Obx(() => buildControlItem(
                      title: 'Weather Condition',
                      showSwitch: true,
                      switchValue: controller.isWeatherConditionOn.value,
                      onSwitchChanged: controller.toggleWeatherCondition,
                      isRound: isRound,
                    )),
                Obx(() => buildControlItem(
                      title: 'Guardian Angel',
                      showSwitch: true,
                      switchValue: controller.isGuardianAngelOn.value,
                      onSwitchChanged: controller.toggleGuardianAngel,
                      isRound: isRound,
                    )),
                Obx(() => buildControlItem(
                      title: 'Location Based',
                      showSwitch: true,
                      switchValue: controller.isLocationConditionOn.value,
                      onSwitchChanged: controller.toggleLocationBased,
                      isRound: isRound,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildControlItem({
    required String title,
    bool showSwitch = false,
    bool showAddButton = false,
    bool switchValue = false,
    bool isRound = false,
    ValueChanged<bool>? onSwitchChanged,
    VoidCallback? onAddPressed,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isRound ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.grayBlack,
        borderRadius: BorderRadius.circular(40),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isRound ? 5 : 10,
        vertical: isRound ? 0 : 1,
      ),
      child: Row(
        mainAxisAlignment:
            isRound ? MainAxisAlignment.center : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isRound ? 10 : 12,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (showSwitch && !isRound)
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: AppColors.green,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.black26,
              ),
            ),
          if (showAddButton && !isRound)
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.green),
              onPressed: onAddPressed,
            ),
          // Keep round layout untouched
          if (isRound && showSwitch)
            Flexible(
              child: Transform.scale(
                scale: 0.6,
                child: Switch(
                  value: switchValue,
                  onChanged: onSwitchChanged,
                  activeColor: AppColors.green,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.black26,
                ),
              ),
            ),
        ],
      ),
    );
  }
}