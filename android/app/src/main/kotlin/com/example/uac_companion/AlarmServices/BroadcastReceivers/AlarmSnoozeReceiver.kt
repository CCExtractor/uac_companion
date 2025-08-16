package com.ccextractor.uac_companion

import android.app.*
import android.content.*
import android.os.Build
import android.util.Log
import com.ccextractor.uac_companion.communication.WatchAlarmSender

class AlarmSnoozeReceiver : BroadcastReceiver() {
    final val TAG = "AlarmSnoozeReceiver"
//!need fixes alarm snoozes but with warning - W/Ringtone: Neither local nor remote playback available that makes the alarm to ring after 5 min but the alrm do not ring
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra("alarmId", -1)
        val watchId = intent.getIntExtra("watchId", -1)
        val hour = intent.getIntExtra("hour", -1)
        val minute = intent.getIntExtra("minute", -1)
        // val isSnoozed = intent.getBooleanExtra("isSnoozed", false)        
        val fromPhone = intent.getBooleanExtra("fromPhone", false) ?: false
        Log.d(TAG, "received intents: $alarmId, $watchId, ")

        if (!fromPhone) {
            WatchAlarmSender.sendActionToPhone(context, "snooze", watchId, alarmId)
        }

        Log.d(TAG, "Snoozing alarmId=$alarmId & watchId: $watchId for +5 minute...")

        // Stop current sound/vibration/notification
        AlarmServiceHolder.ringtone?.stop()
        AlarmServiceHolder.vibrator?.cancel()
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(NOTIFICATION_ID)

        // Reschedule the alarm 5 minute ahead
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        // val triggerAtMillis = System.currentTimeMillis() + 300_000
        val triggerAtMillis = System.currentTimeMillis() + 3_000

        val snoozeIntent = Intent(context, AlarmBroadcastReceiver::class.java).apply {
            putExtra("alarmId", alarmId)
            putExtra("watchId", watchId)
            putExtra("hour", hour)
            putExtra("minute", minute)
            putExtra("isSnoozed", true)
            action = "com.ccextractor.uac_companion.ALARM_TRIGGERED_$watchId"
        }
        val snoozeRequestCode = (watchId % 32767) + 1000000
        val snoozePendingIntent = PendingIntent.getBroadcast(
            context,
            // alarmId, // Same ID, reused for snooze
            snoozeRequestCode,
            snoozeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, snoozePendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, snoozePendingIntent)
        }

        Log.d(TAG, "→ Snoozed alarmId=$alarmId to $triggerAtMillis")
    }
}