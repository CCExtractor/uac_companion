import 'package:flutter/material.dart';
import 'package:uac_companion/app/utils/colors.dart' as uac_colors;
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class ScreenActivityTimer extends StatefulWidget {
  final String selectedLabel;

  const ScreenActivityTimer({super.key, required this.selectedLabel});

  @override
  State<ScreenActivityTimer> createState() => _ScreenActivityTimerState();
}

class _ScreenActivityTimerState extends State<ScreenActivityTimer> {
  int selectedMinute = 0;

  @override
  Widget build(BuildContext context) {
    final isRound = WatchShapeService.isRound;

    return Scaffold(
      backgroundColor: uac_colors.AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: isRound ? 20 : 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.selectedLabel,
                    style: TextStyle(
                      fontSize: isRound ? 12 : 14,
                      fontWeight: FontWeight.w500,
                      color: uac_colors.AppColors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                      'Select time duration',
                       style: TextStyle(
                      fontSize: isRound ? 12 : 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isRound ? 5 : 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isRound ? 8 : 10,
                      horizontal: isRound ? 25 : 30,
                    ),
                    decoration: BoxDecoration(
                      color: uac_colors.AppColors.grayBlack,
                      borderRadius: BorderRadius.circular(70),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMinutePicker(isRound),
                        Text(
                          'minutes',
                          style: TextStyle(
                            fontSize: isRound ? 10 : 12,
                            color: uac_colors.AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isRound ? 5 : 10),
                  _buildIconButton(
                    Icons.check,
                    () {
                      debugPrint('Selected duration: $selectedMinute minutes');
                      Navigator.pop(context, selectedMinute);
                    },
                    true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinutePicker(bool isRound) {
    return SizedBox(
      height: isRound ? 90 : 100,
      width: isRound ? 40 : 55,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 36,
        perspective: 0.005,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (value) {
          setState(() => selectedMinute = value);
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: List.generate(
            60,
            (index) {
              final isSelected = selectedMinute == index;
              return Center(
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize:
                        isSelected ? (isRound ? 25 : 30) : (isRound ? 20 : 20),
                    color: isSelected
                        ? uac_colors.AppColors.green
                        : uac_colors.AppColors.notSeleted,
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

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap,
    bool isSelected,
  ) {
    final isRound = WatchShapeService.isRound;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isRound ? 5 : 8),
        decoration: BoxDecoration(
          color: isSelected
              ? uac_colors.AppColors.green
              : uac_colors.AppColors.grayBlack,
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
          size: isRound ? 20 : 24,
          color: isSelected
              ? uac_colors.AppColors.background
              : const Color(0xB3FFFFFF),
        ),
      ),
    );
  }
}
