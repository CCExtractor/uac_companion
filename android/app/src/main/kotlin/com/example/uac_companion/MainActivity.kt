package com.example.uac_companion

import android.app.*
import android.content.*
import android.content.pm.PackageManager
import android.os.*
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity : FlutterActivity() {

    private val CHANNEL = "alarm_channel"
    private val NOTIFICATION_PERMISSION_REQUEST_CODE = 1002

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        checkAndRequestPermissions()

        // ! MethodChannel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call,
                result ->
            when (call.method) {
                // ! handles calls for both updated alarm (id != null) and new alarms (id=null)
                "scheduleAlarm" -> {
                    val hour = call.argument<Int>("hour")
                    val minute = call.argument<Int>("minute")
                    val id = call.argument<Int>("alarmId")

                    Log.d(
                            "FlutterToNative",
                            "kotline scheduleAlarm - alarmId=$id, hour=$hour, minute=$minute"
                    )
                    if (id != null && hour != null && minute != null) {
                        scheduleAlarm(id, hour, minute)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGS", "ID, hour or minute missing", null)
                    }
                }
                // ! handles calls from toggle button in the alarm screen
                "cancelAlarm" -> {
                    val id = call.argument<Int>("id")
                    if (id != null) {
                        cancelAlarm(id)
                        result.success(null)
                    } else {
                        result.error("INVALID_ID", "Alarm ID missing", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    // ! Permission handling
    private fun checkAndRequestPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(
                            this,
                            android.Manifest.permission.POST_NOTIFICATIONS
                    ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                        this,
                        arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                        NOTIFICATION_PERMISSION_REQUEST_CODE
                )
                return
            }
        }

        requestExactAlarmPermissionIfNeeded()
    }
    override fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<out String>,
            grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                Log.d("Permission", "Notification permission granted")
                requestExactAlarmPermissionIfNeeded()
            } else {
                Log.e("Permission", "Notification permission denied")
            }
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

    // ! Insert the alarm recevived from UAC in the SQLite first and then call this fucntion with
    private fun scheduleAlarm(id: Int, hour: Int, minute: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        Log.d("AlarmDebug", "Attempting to schedule alarm ID=$id at $hour:$minute")

        cancelExistingAlarm(this, id)

        val pendingIntent = createAlarmPendingIntent(this, id)
        val calendar =
                Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, hour)
                    set(Calendar.MINUTE, minute)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                    if (before(Calendar.getInstance())) add(Calendar.DATE, 1)
                }

        Log.d("AlarmDebug", "Final scheduled time for ID=$id is: ${calendar.time}")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
            )
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
        }
        Log.d("AlarmDebug", "Alarm scheduled with ID=$id")
    }

    private fun cancelAlarm(id: Int) {
        Log.d("AlarmDebug", "Attempting to cancel alarm with ID=$id")
        cancelExistingAlarm(this, id)
        Log.d("AlarmDebug", "Alarm cancelled with ID=$id")
    }

    private fun createAlarmPendingIntent(context: Context, alarmId: Int): PendingIntent {
        val intent =
                Intent(context, AlarmBroadcastReceiver::class.java).apply {
                    action = "com.example.uac_companion.ALARM_TRIGGERED_$alarmId"
                    putExtra("alarm_id", alarmId)
                }
        val pendingIntent =
                PendingIntent.getBroadcast(
                        context,
                        alarmId,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
        Log.d("AlarmDebug", "Created PendingIntent for alarmId=$alarmId, hash=${pendingIntent.hashCode()}")
        return pendingIntent
    }

    private fun cancelExistingAlarm(context: Context, alarmId: Int) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = createAlarmPendingIntent(context, alarmId)

        alarmManager.cancel(pendingIntent)
        Log.d("AlarmDebug", "Cancelled any existing PendingIntent for alarmId=$alarmId")
    }
}
