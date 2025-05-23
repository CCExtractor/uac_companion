//! Still need to fix a lot of UI
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'SmartControl.dart';
import 'dart:async';
import '../controllers/wear_bridge.dart';

class TimePickerScreen extends StatefulWidget {
  final WearShape watchShape;

  const TimePickerScreen({super.key, required this.watchShape});

  @override
  State<TimePickerScreen> createState() => _TimePickerScreenState();
}

class _TimePickerScreenState extends State<TimePickerScreen> {
  late int selectedHour;
  late int selectedMinute;
  late String selectedPeriod;
  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minuteController;
  late FixedExtentScrollController periodController;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedHour =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    selectedMinute = now.minute;
    selectedPeriod = now.hour >= 12 ? 'PM' : 'AM';

    hourController = FixedExtentScrollController(initialItem: selectedHour - 1);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
    periodController = FixedExtentScrollController(
        initialItem: selectedPeriod == 'AM' ? 0 : 1);

    // Receiver code from UAC Mobile
    WearBridge.messages.listen((event) {
      debugPrint("Received from native: $event");

      if (event['type'] == 'message') {
        final path = event['path'];
        final data = event['data'];
        debugPrint("Message Path: $path | Data: $data");
      }

      if (event['type'] == 'data') {
        final interval = event['interval'];
        debugPrint("Data Item Received: $interval");
      }

      if (event['type'] == 'capability') {
        final name = event['name'];
        debugPrint("Capability update: $name");
      }
    });
  }

  void _confirmSelection() async {
    final formattedTime =
        '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')} $selectedPeriod';
    debugPrint('Selected Time: $formattedTime');

    // Send time to phone 
    try {
      await WearBridge.sendMessage(
        nodeId: 'dummy-node-id', //! Replace this 
        path: '/alarm/set_time',
        message: formattedTime,
      );
      debugPrint('Message sent to phone!');
    } catch (e) {
      debugPrint('Failed to send message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16171c),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF444444),
                borderRadius: BorderRadius.circular(70),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInfiniteScroll(
                      1,
                      12,
                      (val) => setState(() => selectedHour = val),
                      selectedHour,
                      hourController),
                  const Text(':',
                      style: TextStyle(fontSize: 28, color: Color(0xffAFFC41))),
                  _buildInfiniteScroll(
                      0,
                      59,
                      (val) => setState(() => selectedMinute = val),
                      selectedMinute,
                      minuteController),
                  _buildFixedScroll(
                      ['AM', 'PM'],
                      (val) => setState(() => selectedPeriod = val),
                      selectedPeriod,
                      periodController),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton(Icons.more_vert, () {}),
                _buildIconButton(Icons.check, _confirmSelection,
                    isSelected: true),
                _buildIconButton(Icons.notifications_active, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SmartControlsScreen()),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfiniteScroll(int min, int max, Function(int) onChanged,
      int selectedValue, FixedExtentScrollController controller) {
    return SizedBox(
      width: 50,
      height: 90,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        onSelectedItemChanged: (index) {
          int newValue = min + index;
          onChanged(newValue);
        },
        itemExtent: 36,
        perspective: 0.005,
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List.generate(
            max - min + 1,
            (index) => Text(
              '${min + index}'.padLeft(2, '0'),
              style: TextStyle(
                fontSize: selectedValue == (min + index) ? 28 : 20,
                color: selectedValue == (min + index)
                    ? const Color(0xffAFFC41)
                    : const Color(0xB3FFFFFF),
                fontWeight: selectedValue == (min + index)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedScroll(List<String> labels, Function(String) onChanged,
      String selectedValue, FixedExtentScrollController controller) {
    return SizedBox(
      width: 36,
      height: 100,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        onSelectedItemChanged: (index) {
          debugPrint('Selected Period: ${labels[index]}');
          onChanged(labels[index]);
        },
        itemExtent: 36,
        perspective: 0.005,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildListDelegate(
          children: labels.map((label) {
            bool isSelected = selectedValue == label;
            return Text(
              label,
              style: TextStyle(
                fontSize: isSelected ? 28 : 20,
                color: isSelected
                    ? const Color(0xffAFFC41)
                    : const Color(0xB3FFFFFF),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap,
      {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xffAFFC41) : const Color(0xFF444444),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(4),
          child: Icon(icon,
              color: isSelected ? Colors.black : const Color(0xB3FFFFFF),
              size: 24),
        ),
      ),
    );
  }
}