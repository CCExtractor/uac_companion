import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import './screens/TimePicker.dart'; // Import the TimePickerScreen file
import 'package:flutter/services.dart';

void main() {
  runApp(const WearTimePickerApp());
}

class WearTimePickerApp extends StatelessWidget {
  const WearTimePickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: TimePickerScreen(watchShape: shape), // Pass the shape here
        );
      },
    );
  }
}