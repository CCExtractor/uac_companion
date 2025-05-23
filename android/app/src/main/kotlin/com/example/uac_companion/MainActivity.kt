package com.example.uac_companion

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private lateinit var wearListeners: WearListeners

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "wear_events")
        .setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                if (events != null) {
                    wearListeners = WearListeners(applicationContext, events)
                }
            }
    
            override fun onCancel(arguments: Any?) {
                // Handle cleanup if needed
            }
        })
    }
}