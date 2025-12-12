import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uac_companion/app/modules/more/view/repeat_selector.dart';
import 'package:uac_companion/app/utils/watch_shape_service.dart';
import 'package:flutter/cupertino.dart';
import '../controller/more_settings_controller.dart';
import '../../../utils/colors.dart';

class MoreSettingsView extends StatelessWidget {
  const MoreSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isRound = WatchShapeService.isRound;

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final days = args['days'] as List<int>? ?? [];
    final snooze = args['snooze'] as int? ?? 5;
    MoreSettingsController.to.init(days, snooze: snooze);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: isRound ? 20.0 : 16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - (isRound ? 40 : 32),
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                        color: AppColors.grayBlack, borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        "Repeat on",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isRound ? 13 : 15,
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
                        size: 14,
                      ),
                      onTap: () => showRepeatOptions(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                        color: AppColors.grayBlack, borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                       contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
                       visualDensity: VisualDensity.compact,
                      title: Text(
                        "Snooze",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isRound ? 13 : 15,
                        ),
                      ),
                      subtitle: Obx(() => Text(
                            "${MoreSettingsController.to.snoozeDuration.value} minutes",
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: isRound ? 10 : 12,
                            ),
                          )),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.green,
                        size: 14,
                      ),
                      onTap: () => showSnoozePicker(context),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.back(result: {
                        'days': MoreSettingsController.to.selectedDays,
                        'snooze': MoreSettingsController.to.snoozeDuration.value,
                      }),
                      child: Container(
                        padding: EdgeInsets.all(isRound ? 6 : 8),
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
          ),
        ),
      ),
    );
  }

  void showSnoozePicker(BuildContext context) {
    final isRound = WatchShapeService.isRound;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: isRound ? 220 : 250,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: AppColors.background,
          child: Column(
            children: [
               Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: isRound ? 8.0 : 12.0,
                ),
                child: Text(
                  "Snooze Duration",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isRound ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                   data: CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: isRound ? 16 : 18,
                      ),
                    ),
                  ),
                  child: CupertinoPicker(
                    itemExtent: isRound ? 28 : 32,
                    scrollController: FixedExtentScrollController(
                      initialItem: MoreSettingsController.to.snoozeDuration.value - 1,
                    ),
                    onSelectedItemChanged: (int index) {
                      MoreSettingsController.to.setSnoozeTime(index + 1);
                    },
                    children: List<Widget>.generate(30, (int index) {
                      return Center(
                        child: Text('${index + 1} min'),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}