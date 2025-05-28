import 'package:flutter/services.dart';

class WearBridge {
  static const _eventChannel = EventChannel("wear_events");
  static const _methodChannel = MethodChannel("wear_methods");

  static Stream<Map<String, dynamic>> get messages =>
      _eventChannel.receiveBroadcastStream().map((event) => Map<String, dynamic>.from(event));

  static Future<void> sendMessage({
    required String nodeId,
    required String path,
    required String message,
  }) async {
    await _methodChannel.invokeMethod("sendMessage", {
      "nodeId": nodeId,
      "path": path,
      "message": message,
    });
  }
}