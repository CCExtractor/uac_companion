import 'package:flutter/material.dart';
import 'package:uac_companion/screens/SmartControl.dart';
import '../utils/Colors.dart';
import 'MoreOptionsScreen.dart';
import 'package:flutter/services.dart';

class TimePickerScreen extends StatefulWidget {
  final bool isRound;
  final int? initialHour;
  final int? initialMinute;
  final int? alarmId;

  const TimePickerScreen({
    super.key,
    required this.isRound,
    this.initialHour,
    this.initialMinute,
    this.alarmId,
  });

  @override
  State<TimePickerScreen> createState() => _TimePickerScreenState();
}

int selectedIconIndex = 1; // Default select check icon

class _TimePickerScreenState extends State<TimePickerScreen> {

static const platform = MethodChannel('alarm_channel');

  Future<void> scheduleAlarm(int hour, int minute) async {
    try {
      await platform.invokeMethod('scheduleAlarm', {
        'hour': hour,
        'minute': minute,
      });
    } on PlatformException catch (e) {
      print("Failed to schedule alarm: '${e.message}'.");
    }
  }

  late int selectedHour;
  late int selectedMinute;
  late String selectedPeriod;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController periodController;

  @override
  void initState() {
    super.initState();

    final hour24 = widget.initialHour ?? DateTime.now().hour;
    final minute = widget.initialMinute ?? DateTime.now().minute;

    selectedHour = hour24 == 0
        ? 12
        : hour24 > 12
            ? hour24 - 12
            : hour24;

    selectedMinute = minute;
    selectedPeriod = hour24 >= 12 ? 'PM' : 'AM';

    hourController = FixedExtentScrollController(initialItem: selectedHour - 1);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    periodController = FixedExtentScrollController(
        initialItem: selectedPeriod == 'AM' ? 0 : 1);
  }
  

void _confirmTime() async {
  int finalHour;
  if (selectedPeriod == 'AM') {
    finalHour = selectedHour == 12 ? 0 : selectedHour;
  } else {
    finalHour = selectedHour == 12 ? 12 : selectedHour + 12;
  }

  await scheduleAlarm(finalHour, selectedMinute); // await here

  Navigator.pop(context, {
    'hour': finalHour,
    'minute': selectedMinute,
    'alarmId': widget.alarmId,
  });
}


  @override
  Widget build(BuildContext context) {
    final isRound = widget.isRound;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: isRound ? 8 : 10, horizontal: isRound ? 15 : 10),
              decoration: BoxDecoration(
                color: AppColors.grayBlack,
                borderRadius: BorderRadius.circular(70),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildInfiniteScroll(1, 12, selectedHour, hourController,
                      (val) {
                    setState(() => selectedHour = val);
                  }),
                  Text(
                    ':',
                    style: TextStyle(
                        fontSize: isRound ? 20 : 28,
                        color: AppColors.notSeleted),
                  ),
                  _buildInfiniteScroll(0, 59, selectedMinute, minuteController,
                      (val) {
                    setState(() => selectedMinute = val);
                  }),
                  _buildFixedScroll(
                      ['AM', 'PM'], selectedPeriod, periodController, (val) {
                    setState(() => selectedPeriod = val);
                  }),
                ],
              ),
            ),
            SizedBox(height: isRound ? 5 : 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton(0, Icons.more_vert, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MoreOptionsScreen()),
                  );
                }),
                _buildIconButton(1, Icons.check, _confirmTime),
                _buildIconButton(2, Icons.notifications_active, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SmartControlsScreen()),
                  );
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfiniteScroll(int min, int max, int selectedValue,
      FixedExtentScrollController controller, Function(int) onChanged) {
    final isRound = widget.isRound;
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
    final isRound = widget.isRound;
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

  Widget _buildIconButton(int index, IconData icon, VoidCallback onTap) {
    final isSelected = selectedIconIndex == index;
    final isRound = widget.isRound;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedIconIndex = index;
          });
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
