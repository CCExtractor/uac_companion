import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../controllers/time_picker_controller.dart';
import '../../more_option_screen.dart';
import '../../smart_control.dart';
import '../../../../watch_shape.dart';

class TimePickerView extends StatefulWidget {
  final int? initialHour;
  final int? initialMinute;
  final int? alarmId;

  const TimePickerView({
    super.key,
    this.initialHour,
    this.initialMinute,
    this.alarmId,
  });

  @override
  State<TimePickerView> createState() => _TimePickerViewState();
}

class _TimePickerViewState extends State<TimePickerView> {
  late final TimePickerController controller;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController periodController;

  @override
  void initState() {
    super.initState();

    controller = Get.put(TimePickerController(
      // isRound: Get.find<DeviceController>().isRound.value,
      initialHour: widget.initialHour,
      initialMinute: widget.initialMinute,
      alarmId: widget.alarmId,
    ));

    final hour24 = widget.initialHour ?? DateTime.now().hour;
    final minute = widget.initialMinute ?? DateTime.now().minute;

    final selectedHour = hour24 == 0
        ? 12
        : hour24 > 12
            ? hour24 - 12
            : hour24;

    final selectedMinute = minute;
    final selectedPeriod = hour24 >= 12 ? 'PM' : 'AM';

    controller.setHour(selectedHour);
    controller.setMinute(selectedMinute);
    controller.setPeriod(selectedPeriod);

    hourController = FixedExtentScrollController(initialItem: selectedHour - 1);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    periodController = FixedExtentScrollController(
        initialItem: selectedPeriod == 'AM' ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final isRound = Get.find<DeviceController>().isRound.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Container(
                      padding: EdgeInsets.symmetric(
                          vertical: isRound ? 8 : 10,
                          horizontal: isRound ? 15 : 10),
                      decoration: BoxDecoration(
                        color: AppColors.grayBlack,
                        borderRadius: BorderRadius.circular(70),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildInfiniteScroll(
                              1,
                              12,
                              controller.selectedHour.value,
                              hourController,
                              controller.setHour),
                          Text(
                            ':',
                            style: TextStyle(
                                fontSize: isRound ? 20 : 28,
                                color: AppColors.notSeleted),
                          ),
                          _buildInfiniteScroll(
                              0,
                              59,
                              controller.selectedMinute.value,
                              minuteController,
                              controller.setMinute),
                          _buildFixedScroll(
                              ['AM', 'PM'],
                              controller.selectedPeriod.value,
                              periodController,
                              controller.setPeriod),
                        ],
                      ),
                    )),
                SizedBox(height: isRound ? 5 : 15),
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton(0, Icons.more_vert, () {
                          controller.setSelectedIcon(0);
                          Get.to(() => const MoreOptionsScreen());
                        }, controller.selectedIconIndex.value == 0),
                        _buildIconButton(1, Icons.check, () {
                          controller.setSelectedIcon(1);
                          // controller.confirmTime(widget.alarmId);
                          controller.confirmTime();
                          // controller.scheduleAlarm(
                          //   controller.selectedHour.value,
                          //   controller.selectedMinute.value,
                          //   widget.alarmId,
                          // );
                        }, controller.selectedIconIndex.value == 1),
                        _buildIconButton(2, Icons.notifications_active, () {
                          controller.setSelectedIcon(2);
                          Get.to(() => const SmartControlsScreen());
                        }, controller.selectedIconIndex.value == 2),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfiniteScroll(int min, int max, int selectedValue,
      FixedExtentScrollController controller, Function(int) onChanged) {
    final isRound = Get.find<DeviceController>().isRound.value;
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
                    fontSize: isSelected
                        ? (isRound ? 25 : 30)
                        : isRound
                            ? 20
                            : 20,
                    color: isSelected ? AppColors.green : AppColors.notSeleted,
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

  Widget _buildFixedScroll(List<String> items, String selectedValue,
      FixedExtentScrollController controller, Function(String) onChanged) {
    final isRound = Get.find<DeviceController>().isRound.value;

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
                    fontSize: isSelected
                        ? (isRound ? 23 : 25)
                        : isRound
                            ? 20
                            : 20,
                    color: isSelected ? AppColors.green : AppColors.notSeleted,
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
      int index, IconData icon, VoidCallback onTap, bool isSelected) {
    final isRound = Get.find<DeviceController>().isRound.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () {
          controller.setSelectedIcon(index);
          onTap();
        },
        child: Container(
          padding: EdgeInsets.all(isRound ? 5 : 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.green : AppColors.grayBlack,
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
            color: isSelected ? AppColors.background : const Color(0xB3FFFFFF),
          ),
        ),
      ),
    );
  }
}
