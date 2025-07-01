import 'package:flutter/material.dart';

// Formates the time from 24hrs to 12hrs and seperates the AM/PM for better formatting
TextSpan formattedTimeSpan({
  required String time,
  required bool isRound,
}) {
  final parts = time.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);

  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  final amPm = hour >= 12 ? 'PM' : 'AM';

  return TextSpan(
    children: [
      TextSpan(
        text: '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ',
        style: TextStyle(
          fontSize: isRound ? 16 : 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      TextSpan(
        text: amPm,
        style: TextStyle(
          fontSize: isRound ? 10 : 12,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    ],
  );
}
