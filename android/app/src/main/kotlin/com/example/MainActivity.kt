package com.ccextractor.uac_companion

import android.Manifest
import android.app.AlarmManager
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ccextractor.uac_companion.communication.WatchAlarmSender
import com.ccextractor.uac_companion.communication.parseAlarm
import com.ccextractor.uac_companion.communication.UACDataLayerListenerService

class MainActivity : FlutterActivity() {

    private val CHANNEL = "uac_alarm_channel"
    private val NATIVE_TO_FLUTTER = "uac_kotlin_to_flutter"
    private val ALARM_SYNC_CHANNEL = "uac_alarm_sync"
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 1002

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        checkAndRequestPermissions()
        UACDataLayerListenerService.flutterEngine = flutterEngine

        // Phone alarm scheduling / cancellation
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scheduleAlarm" -> {
                        AlarmScheduler.scheduleNextAlarm(this)
                        result.success(null)
                    }
                    "cancelAlarm" -> {
                        val id = call.argument<Int>("id")
                        val watchId = call.argument<Int>("watchId") ?: -1
                        // val phoneId = call.argument<String>("phoneId") ?: ""
                        if (id != null) {
                            AlarmScheduler.cancelAlarm(this, watchId)
                            result.success(null)
                        } else {
                            result.error("INVALID_ID", "Alarm ID missing", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // Watch → Phone communication
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_SYNC_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sendAlarmToPhone" -> {
                        try {
                            val args = call.arguments as Map<*, *>
                            val alarm = parseAlarm(args)
                            WatchAlarmSender.sendAlarmToPhone(this, alarm)
                            result.success("sent")
                        } catch (e: Exception) {
                            Log.e("UAC_WatchChannel", "Failed to parse/send alarm", e)
                            result.error("error", "Invalid alarm data", null)
                        }
                    }
                    "sendActionToPhone" -> {
                        try {
                            val action = call.argument<String>("action") ?: ""
                            // val phoneId = call.argument<String>("phoneId") ?: ""
                            val watchId = call.argument<Int>("watchId") ?: -1
                            val alarmId = call.argument<Int>("id") ?: -1

                            Log.d("MainActivityFile", "$action for watchId: $watchId and id: $alarmId")
                            WatchAlarmSender.sendActionToPhone(this, action, watchId, alarmId)
                            result.success("sent")
                        } catch (e: Exception) {
                            Log.e("UAC_WatchChannel", "Failed to send action", e)
                            result.error("error", "Invalid action data", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun checkAndRequestPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(
                    this, Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                    NOTIFICATION_PERMISSION_REQUEST_CODE
                )
            }
        } else {
            requestExactAlarmPermissionIfNeeded()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE &&
            grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED
        ) {
            Log.d("Permission", "Notification permission granted")
            requestExactAlarmPermissionIfNeeded()
        } else {
            Log.e("Permission", "Notification permission denied")
        }
    }

    private fun requestExactAlarmPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(AlarmManager::class.java)
            if (!alarmManager.canScheduleExactAlarms()) {
                val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(intent)
            }
        }
    }
}