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
                    val days = call.argument<String>("days") ?: "Once"

                    if (id != null && hour != null && minute != null) {
                        scheduleAlarm(id, hour, minute, days)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGS", "ID, hour, or minute missing", null)
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

    // ! Insert the alarm recevived from UAC in the SQLite first and then call this fucntion.
    private fun scheduleAlarm(id: Int, hour: Int, minute: Int, days: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        Log.d("Kotlin-AlarmDebug", "Scheduling alarm with ID=$id, time=$hour:$minute, days=$days")

        cancelExistingAlarmsForId(id)

        // Parse the days string into a list of Calendar.DAY_OF_WEEK constants
        val daysList =
                when (days) {
                    "Once" -> listOf(Calendar.getInstance().get(Calendar.DAY_OF_WEEK))
                    "Weekdays" ->
                            listOf(
                                    Calendar.MONDAY,
                                    Calendar.TUESDAY,
                                    Calendar.WEDNESDAY,
                                    Calendar.THURSDAY,
                                    Calendar.FRIDAY
                            )
                    "Daily" ->
                            listOf(
                                    Calendar.SUNDAY,
                                    Calendar.MONDAY,
                                    Calendar.TUESDAY,
                                    Calendar.WEDNESDAY,
                                    Calendar.THURSDAY,
                                    Calendar.FRIDAY,
                                    Calendar.SATURDAY
                            )
                    else -> {
                        days.split(",")
                                .mapNotNull { dayStr ->
                                    dayStr.trim().toIntOrNull()?.let { dayNum ->
                                        // Add 1 to convert 0-based (Sunday=0) to Calendar constants (Sunday=1)
                                        val androidDay = dayNum + 1
                                        if (androidDay in 1..7) androidDay else null
                                    }
                                }
                                .ifEmpty { listOf(-1) }
                    }
                }
        Log.d("Kotlin-AlarmDebug", "Parsed days list: $daysList")

        val now = Calendar.getInstance()

        if (daysList.contains(-1)) {
            // ! One-time alarm
            val calendar =
                    Calendar.getInstance().apply {
                        set(Calendar.HOUR_OF_DAY, hour)
                        set(Calendar.MINUTE, minute)
                        set(Calendar.SECOND, 0)
                        set(Calendar.MILLISECOND, 0)
                        if (before(now)) add(Calendar.DAY_OF_YEAR, 1)
                    }

            val pendingIntent = createAlarmPendingIntent(this, id, id * 10)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        calendar.timeInMillis,
                        pendingIntent
                )
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
            }
            Log.d("Kotlin-AlarmDebug", "1-time alarm scheduled with ID=$id at ${calendar.time}")
        } else {
            // ! Repeat alarms for given days
            for (dayOfWeek in daysList) {
                val calendar =
                        Calendar.getInstance().apply {
                            set(Calendar.HOUR_OF_DAY, hour)
                            set(Calendar.MINUTE, minute)
                            set(Calendar.SECOND, 0)
                            set(Calendar.MILLISECOND, 0)
                            set(Calendar.DAY_OF_WEEK, dayOfWeek)
                            if (before(now)) add(Calendar.WEEK_OF_YEAR, 1)
                        }
                val requestCode = generateRequestCode(id, dayOfWeek)
                val pendingIntent = createAlarmPendingIntent(this, id, requestCode)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(
                            AlarmManager.RTC_WAKEUP,
                            calendar.timeInMillis,
                            pendingIntent
                    )
                } else {
                    alarmManager.setExact(
                            AlarmManager.RTC_WAKEUP,
                            calendar.timeInMillis,
                            pendingIntent
                    )
                }
                Log.d(
                        "Kotlin-AlarmDebug",
                        "Scheduled alarm ID=$id for day $dayOfWeek at ${calendar.time}"
                )
            }
        }
    }

    private fun generateRequestCode(alarmId: Int, dayOfWeek: Int): Int {
        return alarmId * 10 + dayOfWeek
    }

    private fun cancelExistingAlarmsForId(alarmId: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val oneTimeIntent = createAlarmPendingIntent(this, alarmId, alarmId * 10)
        alarmManager.cancel(oneTimeIntent)
        Log.d(
                "Kotlin-AlarmDebug",
                "Cancelling one-time alarm for ID=$alarmId (requestCode=${alarmId * 10})"
        )

        for (dayOfWeek in 1..7) {
            val pendingIntent =
                    createAlarmPendingIntent(this, alarmId, generateRequestCode(alarmId, dayOfWeek))
            alarmManager.cancel(pendingIntent)
            Log.d(
                    "Kotlin-AlarmDebug",
                    "Cancelling existing alarm for ID=$alarmId on dayOfWeek=$dayOfWeek"
            )
        }
    }

    private fun createAlarmPendingIntent(
            context: Context,
            alarmId: Int,
            requestCode: Int
    ): PendingIntent {
        val intent =
                Intent(context, AlarmBroadcastReceiver::class.java).apply {
                    action = "com.example.uac_companion.ALARM_TRIGGERED_$alarmId"
                    putExtra("alarmId", alarmId)
                }
        return PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun cancelAlarm(id: Int) {
        Log.d("Kotlin-AlarmDebug", "Attempting to cancel alarm with ID=$id")
        cancelExistingAlarmsForId(id)
        Log.d("Kotlin-AlarmDebug", "Alarm cancelled with ID=$id")
    }
}