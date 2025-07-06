//! need a look
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/more/view/more_settings_view.dart';
import 'package:uac_companion/app/utils/colors.dart' as uac_colors;
import 'package:uac_companion/app/utils/watch_shape_service.dart' as watch_shape;
import '../controllers/alarm_setup_controllers.dart';
import '../../smart_control.dart';

class AlarmSetupView extends StatelessWidget {
  const AlarmSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.find<AlarmSetupControllers>();
    final isRound = watch_shape.WatchShapeService.isRound;

    return Scaffold(
      backgroundColor: uac_colors.AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isRound ? 8 : 10,
                        horizontal: isRound ? 15 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: uac_colors.AppColors.grayBlack,
                        borderRadius: BorderRadius.circular(70),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInfiniteScroll(
                            1,
                            12,
                            AlarmSetupControllers.to.selectedHour.value,
                            AlarmSetupControllers.to.hourController,
                            AlarmSetupControllers.to.setHour,
                          ),
                          Text(
                            ':',
                            style: TextStyle(
                              fontSize: isRound ? 20 : 28,
                              color: uac_colors.AppColors.notSeleted,
                            ),
                          ),
                          _buildInfiniteScroll(
                            0,
                            59,
                            AlarmSetupControllers.to.selectedMinute.value,
                            AlarmSetupControllers.to.minuteController,
                            AlarmSetupControllers.to.setMinute,
                          ),
                          _buildFixedScroll(
                            ['AM', 'PM'],
                            AlarmSetupControllers.to.selectedPeriod.value,
                            AlarmSetupControllers.to.periodController,
                            AlarmSetupControllers.to.setPeriod,
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: isRound ? 5 : 15),
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton(0, Icons.more_vert, () async {
                          // final result =await Get.toNamed(AppRoutes.moreSettings);
                          final result = await Get.to(() => const MoreSettingsView(),arguments: AlarmSetupControllers.to.selectedDays,);
                          if (result is List<int>) {
                            AlarmSetupControllers.to.selectedDays.value = result;
                          }
                        }, AlarmSetupControllers.to.selectedIconIndex.value == 0),
                        _buildIconButton(1, Icons.check, () {
                          AlarmSetupControllers.to.confirmTime();
                        }, AlarmSetupControllers.to.selectedIconIndex.value == 1),
                        _buildIconButton(2, Icons.notifications_active, () {
                          Get.to(() => const SmartControlsScreen());
                        }, AlarmSetupControllers.to.selectedIconIndex.value == 2),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfiniteScroll(
    int min,
    int max,
    int selectedValue,
    FixedExtentScrollController controller,
    Function(int) onChanged,
  ) {
    final isRound = watch_shape.WatchShapeService.isRound;
    return SizedBox(
      width: isRound ? 40 : 55,
      height: isRound ? 90 : 100,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 36,
        perspective: 0.005,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onChanged(min + index);
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List.generate(
            max - min + 1,
            (index) {
              final value = min + index;
              final isSelected = selectedValue == value;
              return Center(
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize:
                        isSelected ? (isRound ? 25 : 30) : (isRound ? 20 : 20),
                    color: isSelected ? uac_colors.AppColors.green : uac_colors.AppColors.notSeleted,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFixedScroll(
    List<String> items,
    String selectedValue,
    FixedExtentScrollController controller,
    Function(String) onChanged,
  ) {
    final isRound = watch_shape.WatchShapeService.isRound;
    return SizedBox(
      width: isRound ? 40 : 55,
      height: isRound ? 90 : 100,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 36,
        perspective: 0.005,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onChanged(items[index]);
        },
        childDelegate: ListWheelChildListDelegate(
          children: items.map((item) {
            final isSelected = selectedValue == item;
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: isRound ? 0 : 4),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize:
                        isSelected ? (isRound ? 23 : 25) : (isRound ? 20 : 20),
                    color: isSelected ? uac_colors.AppColors.green : uac_colors.AppColors.notSeleted,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIconButton(
    int index,
    IconData icon,
    VoidCallback onTap,
    bool isSelected,
  ) {
    final isRound = watch_shape.WatchShapeService.isRound;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isRound ? 5 : 8),
          decoration: BoxDecoration(
            color: isSelected ? uac_colors.AppColors.green : uac_colors.AppColors.grayBlack,
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
            size: 24,
            color: isSelected ? uac_colors.AppColors.background : const Color(0xB3FFFFFF),
          ),
        ),
      ),
    );
  }
}