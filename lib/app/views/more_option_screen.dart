import 'package:flutter/material.dart';
import 'package:uac_companion/app/utils/colors.dart';

class MoreOptionsScreen extends StatelessWidget {
  const MoreOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text(
          "More Options",
          style: TextStyle(color: AppColors.green, fontSize: 18),
        ),
      ),
    );
  }
}