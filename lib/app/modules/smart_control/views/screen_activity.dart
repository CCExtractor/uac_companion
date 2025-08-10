import 'package:flutter/material.dart';
import 'package:uac_companion/app/utils/colors.dart';
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class ScreenActivityDetailScreen extends StatefulWidget {
  const ScreenActivityDetailScreen({super.key});

  @override
  State<ScreenActivityDetailScreen> createState() =>
      _ScreenActivityDetailScreenState();
}

class _ScreenActivityDetailScreenState
    extends State<ScreenActivityDetailScreen> {
  int selectedMinute = 0;

  @override
  Widget build(BuildContext context) {
    final isRound = WatchShapeService.isRound;
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isRound ? deviceSize.width * 0.08 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                'Screen Activity Duration',
                style: TextStyle(
                  fontSize: isRound ? 12 : 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.green,
                ),
              ),
              SizedBox(height: isRound ? 12 : 20),

              // Picker + Label Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMinutePicker(isRound, deviceSize.height),
                  const SizedBox(width: 12),
                  Text(
                    'minutes',
                    style: TextStyle(
                      fontSize: isRound ? 10 : 14,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isRound ? 20 : 30),

              // Confirm Button
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinutePicker(bool isRound, double deviceHeight) {
    return SizedBox(
      height: isRound ? deviceHeight * 0.25 : 150,
      width: isRound ? 70 : 100,
      child: ListWheelScrollView.useDelegate(
        itemExtent: isRound ? 28 : 40,
        perspective: 0.003, // smoother depth
        diameterRatio: 2.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (value) {
          setState(() => selectedMinute = value);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            return Center(
              child: Text(
                index.toString(),
                style: TextStyle(
                  fontSize: isRound ? 12 : 18,
                  fontWeight:
                      selectedMinute == index ? FontWeight.bold : FontWeight.w400,
                  color: selectedMinute == index
                      ? AppColors.green
                      : Colors.white54,
                ),
              ),
            );
          },
          childCount: 60,
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton.icon(
      onPressed: () {
        debugPrint('Selected duration: $selectedMinute minutes');
        Navigator.pop(context, selectedMinute);
      },
      icon: const Icon(Icons.check, color: AppColors.background),
      label: const Text(
        'Confirm',
        style: TextStyle(color: AppColors.background),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}
