package com.ccextractor.uac_companion

import android.Manifest
import android.app.AlarmManager
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "uac_alarm_channel"
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 1002

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        checkAndRequestPermissions()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    AlarmScheduler.scheduleNextAlarm(this)
                    result.success(null)
                }
                "cancelAlarm" -> {
                    val id = call.argument<Int>("id")
                    if (id != null) {
                        AlarmScheduler.cancelAlarm(this, id)
                        result.success(null)
                    } else {
                        result.error("INVALID_ID", "Alarm ID missing", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkAndRequestPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) !=
                            PackageManager.PERMISSION_GRANTED
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
                val intent =
                        Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        }
                startActivity(intent)
            }
        }
    }
}
