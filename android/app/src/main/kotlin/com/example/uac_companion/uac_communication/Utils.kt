package com.ccextractor.uac_companion.communication

import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import com.ccextractor.uac_companion.communication.UACDataLayerListenerService.Companion.flutterEngine

fun notifyFlutterOfAlarmInsert() {
    val messenger = flutterEngine?.dartExecutor?.binaryMessenger
    if (messenger != null) {
        Handler(Looper.getMainLooper()).post {
            MethodChannel(messenger, "uac_alarm_channel")
                .invokeMethod("onAlarmInserted", null)
        }
    } else {
        Log.w("AlarmDBService", "⚠️ FlutterEngine is null — cannot notify Flutter")
    }
}

fun parseDaysFromBinaryString(binaryString: String): List<Int> {
    return binaryString.mapIndexedNotNull { index, char ->
        // if (char == '1') index + 1 else null
        if (char == '1') index else null

    }
}
