//! Rough code just to test
import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xff16171c),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Picker + Label Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minute Picker
              SizedBox(
                height: 150,
                width: 100,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 40,
                  perspective: 0.002,
                  diameterRatio: 2.0,
                  onSelectedItemChanged: (value) {
                    setState(() {
                      selectedMinute = value;
                    });
                  },
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      return Center(
                        child: Text(
                          index.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xffAFFC41),
                          ),
                        ),
                      );
                    },
                    childCount: 60,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'minutes',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xffAFFC41),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Confirm Button
          ElevatedButton.icon(
            onPressed: () {
              debugPrint('Selected duration: $selectedMinute minutes');
              Navigator.pop(context); 
            },
            icon: const Icon(Icons.check, color: Color(0xff16171c)),
            label: const Text(
              'Confirm',
              style: TextStyle(color: Color(0xff16171c)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffAFFC41),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}