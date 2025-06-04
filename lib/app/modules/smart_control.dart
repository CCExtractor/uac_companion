//! NO functionality added till now
import 'package:flutter/material.dart';
import 'screen_activity.dart';

class SmartControlsScreen extends StatefulWidget {
  const SmartControlsScreen({super.key});

  @override
  State<SmartControlsScreen> createState() => _SmartControlsScreenState();
}

class _SmartControlsScreenState extends State<SmartControlsScreen> {
  bool isScreenActivityOn = false;
  bool isGuardianAngelOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff16171c),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Smart Controls',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xffAFFC41),
                  fontWeight: FontWeight.normal,
                ),
              ),
              _buildControlItem(
                'Screen Activity',
                showSwitch: true,
                switchValue: isScreenActivityOn,
                onSwitchChanged: (val) {
                  setState(() => isScreenActivityOn = val);
                  if (val) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ScreenActivityDetailScreen(),
                      ),
                    );
                  }
                },
              ),
              _buildControlItem(
                'Weather Condition',
                showAddButton: true,
              ),
              _buildControlItem(
                'Guardian Angel',
                showSwitch: true,
                switchValue: isGuardianAngelOn,
                onSwitchChanged: (val) {
                  setState(() => isGuardianAngelOn = val);
                },
              ),
              _buildControlItem(
                'Location Based',
                showAddButton: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlItem(
    String title, {
    bool showSwitch = false,
    bool showAddButton = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xff595f6b),
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          if (showSwitch)
            Transform.scale(
              scale: 0.7,
              child: Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: const Color(0xffAFFC41),
                inactiveTrackColor: Colors.grey,
              ),
            ),
          if (showAddButton)
            IconButton(
              icon: const Icon(Icons.add_circle,
                  color: Color(0xffB8E9C4)),
              onPressed: () {
                debugPrint('$title: Add button pressed');
              },
            ),
        ],
      ),
    );
  }
}