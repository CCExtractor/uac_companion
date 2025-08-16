import 'package:flutter/material.dart';
import 'package:uac_companion/app/modules/smart_control/views/weather_condition_picker.dart';
import 'package:uac_companion/app/utils/colors.dart' as uac_colors;
import 'package:uac_companion/app/utils/watch_shape_service.dart';

enum WeatherConditionType {
  ringWhenMatch,
  cancelWhenMatch,
  ringWhenDifferent,
  cancelWhenDifferent,
}

class WeatherConditionScreen extends StatefulWidget {
  const WeatherConditionScreen({super.key});

  @override
  State<WeatherConditionScreen> createState() => _WeatherConditionScreenState();
}

class _WeatherConditionScreenState extends State<WeatherConditionScreen> {
  int? selectedIndex;

  final List<Map<String, dynamic>> options = [
    {'label': 'Ring when Match', 'type': WeatherConditionType.ringWhenMatch},
    {'label': 'Cancel when Match', 'type': WeatherConditionType.cancelWhenMatch},
    {'label': 'Ring when Different', 'type': WeatherConditionType.ringWhenDifferent},
    {'label': 'Cancel when Different', 'type': WeatherConditionType.cancelWhenDifferent},
  ];

  void _onSelect(int index) {
    setState(() {
      selectedIndex = index;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Weather_condition_picker(selectedLabel: options[index]['label']),
      ),
    );
  }

  IconData _getWeatherConditionIcon(WeatherConditionType type) {
    switch (type) {
      case WeatherConditionType.ringWhenMatch:
        return Icons.alarm;
      case WeatherConditionType.cancelWhenMatch:
        return Icons.alarm_off;
      case WeatherConditionType.ringWhenDifferent:
        return Icons.alarm_on;
      case WeatherConditionType.cancelWhenDifferent:
        return Icons.cancel;
      default:
        return Icons.cloud;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRound = WatchShapeService.isRound;

    return Scaffold(
      backgroundColor: uac_colors.AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: isRound ? 12 : 10),
            Text(
              'Weather Condition',
              style: TextStyle(
                fontSize: isRound ? 12 : 15,
                fontWeight: FontWeight.normal,
                color: uac_colors.AppColors.green,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(
                  top: isRound ? 6 : 8,
                  bottom: isRound ? 40 : 8, // extra space for round watches
                  left: isRound ? 10 : 14,
                  right: isRound ? 10 : 14,
                ),
                itemCount: options.length,
                itemBuilder: (context, i) => _buildWeatherButton(
                  options[i]['label'],
                  options[i]['type'],
                  i,
                  isRound,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherButton(
    String label,
    WeatherConditionType type,
    int index,
    bool isRound,
  ) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _onSelect(index),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: isRound ? 4 : 6),
        padding: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: isRound ? 12 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? uac_colors.AppColors.green.withOpacity(0.2)
              : uac_colors.AppColors.grayBlack,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment:
              isRound ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              _getWeatherConditionIcon(type),
              size: isRound ? 16 : 18,
              color: isSelected ? uac_colors.AppColors.green : Colors.white,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isSelected ? (isRound ? 13 : 15) : (isRound ? 12 : 14),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? uac_colors.AppColors.green : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
