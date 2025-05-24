import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import './screens/Home.dart';

void main() {
  runApp(const UacCompanion());
}

class UacCompanion extends StatelessWidget {
  const UacCompanion({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        final bool isRound = shape == WearShape.round;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: Home(isRound: isRound),
        );
      },
    );
  }
}
