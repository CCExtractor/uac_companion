import 'package:flutter/widgets.dart';

class WatchShapeService {
  static late bool isRound;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.width / size.height;
    isRound = (aspectRatio - 1.0).abs() < 0.05;
    debugPrint('Watch shape initialized: isRound = $isRound (w=${size.width}, h=${size.height})');
  }
}