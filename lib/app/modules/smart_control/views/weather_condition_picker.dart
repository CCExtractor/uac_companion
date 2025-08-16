import 'package:flutter/material.dart';
import 'package:uac_companion/app/utils/colors.dart' as uac_colors;
import 'package:uac_companion/app/utils/watch_shape_service.dart';

class Weather_condition_picker extends StatefulWidget {
  final String selectedLabel;
  const Weather_condition_picker({super.key, required this.selectedLabel});

  @override
  State<Weather_condition_picker> createState() => _Weather_condition_pickerState();
}

class _Weather_condition_pickerState extends State<Weather_condition_picker> {
  final List<String> weatherOptions = [
    "Sunny",
    "Cloudy",
    "Rainy",
    "Windy",
    "Stormy",
  ];

  final Set<int> selectedIndexes = {};
  int centerIndex = 0;

  void toggleWeather(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  String getSelectedWeatherString() {
    if (selectedIndexes.isEmpty) return '';
    final sorted = selectedIndexes.toList()..sort();
    return sorted.map((i) => weatherOptions[i]).join(', ');
  }

  @override
Widget build(BuildContext context) {
  final isRound = WatchShapeService.isRound;

  return Scaffold(
    backgroundColor: uac_colors.AppColors.background,
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isRound ? 8.0 : 12.0,
          horizontal: isRound ? 8.0 : 12.0,
        ),
        child: Column(
          children: [
            SizedBox(height: isRound ? 20 : 20),
            Text(
              'Select Weather Condition',
              style: TextStyle(
                fontSize: isRound ? 12 : 14,
                fontWeight: FontWeight.normal,
                color: uac_colors.AppColors.green,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isRound ? 2 : 8),
            SizedBox(
              height: isRound ? 95 : 110,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                decoration: BoxDecoration(
                  color: uac_colors.AppColors.grayBlack,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 35,
                  diameterRatio: 1.4,
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.002,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      centerIndex = index;
                    });
                  },
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: List.generate(
                      weatherOptions.length,
                      (index) {
                        final isSelected = selectedIndexes.contains(index);

                        return GestureDetector(
                          onTap: () => toggleWeather(index),
                          child: Center(
                            child: Text(
                              weatherOptions[index],
                              style: TextStyle(
                                fontSize: (isSelected ? 24 : 20),
                                fontWeight: (isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                                color: (isSelected
                                    ? uac_colors.AppColors.green
                                    : Colors.white.withOpacity(0.7)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: isRound ? 2 : 8),
            GestureDetector(
              onTap: () {
                final selectedWeather = selectedIndexes
                    .map((i) => weatherOptions[i])
                    .toList();
                debugPrint("Selected weather: $selectedWeather");
                Navigator.pop(context, selectedWeather);
              },
              child: Container(
                padding: EdgeInsets.all(isRound ? 8 : 10),
                decoration: const BoxDecoration(
                  color: uac_colors.AppColors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: isRound ? 22 : 26,
                  color: uac_colors.AppColors.background,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
