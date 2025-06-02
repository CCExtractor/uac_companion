import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/alarm_data.dart';
import '../controllers/home_controller.dart';
import '../../../utils/colors.dart';
import '../../../../watch_shape.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
Widget build(BuildContext context) {
  final HomeController controller = Get.find();
  final deviceController = Get.find<DeviceController>();

  return Obx(() {
    final isRound = deviceController.isRound.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20, bottom: 30),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isRound ? 25 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //! Add Alarm Button
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.grayBlack,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: AppColors.green, size: 28),
                  onPressed: () => {controller.navigateToTimePicker(context)},
                  padding: EdgeInsets.all(isRound ? 10 : 12),
                  constraints: BoxConstraints(
                    minWidth: isRound ? 40 : 50,
                    minHeight: isRound ? 40 : 50,
                  ),
                ),
              ),

              //! Alarm List
              Obx(() {
                final alarms = controller.alarms;
                if (alarms.isEmpty) {
                  return Center(
                    child: Text(
                      "Add a new Alarm",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isRound ? 12 : 16,
                      ),
                    ),
                  );
                }
                return Column(
                  children: alarms.map<Widget>((Alarm alarm) {
                    return GestureDetector(
                      onTap: () => {controller.navigateToTimePicker(context, alarm: alarm),},
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: EdgeInsets.only(
                          left: isRound ? 11 : 14,
                          top: isRound ? 1 : 3,
                          bottom: isRound ? 1 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grayBlack,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alarm.days,
                                  style: TextStyle(
                                    color: AppColors.green,
                                    fontSize: isRound ? 8 : 10,
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${alarm.time.split(' ')[0]} ',
                                        style: TextStyle(
                                          fontSize: isRound ? 16 : 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: alarm.time.split(' ')[1],
                                        style: TextStyle(
                                          fontSize: isRound ? 10 : 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Transform.scale(
                              scale: isRound ? 0.7 : 0.8,
                              child: Switch(
                                value: alarm.enabled,
                                onChanged: (_) => controller.toggleAlarm(controller.alarms.indexOf(alarm)),
                                activeColor: AppColors.green,
                                inactiveThumbColor: Colors.grey,
                                inactiveTrackColor: Colors.black26,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  });
}
}