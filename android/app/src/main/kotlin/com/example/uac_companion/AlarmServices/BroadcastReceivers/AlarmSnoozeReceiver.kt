package com.ccextractor.uac_companion

import android.app.*
import android.content.*
import android.os.Build
import android.util.Log
import com.ccextractor.uac_companion.communication.WatchAlarmSender

class AlarmSnoozeReceiver : BroadcastReceiver() {
    final val TAG = "AlarmSnoozeReceiver"
//!need fixes alarm snoozes but with warning - W/Ringtone: Neither local nor remote playback available
    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra("alarmId", -1)
        val hour = intent.getIntExtra("hour", -1)
        val minute = intent.getIntExtra("minute", -1)

        WatchAlarmSender.sendActionToPhone(context, "dismiss")

        Log.d(TAG, "Snoozing alarmId=$alarmId for +1 minute...")

        // Stop current sound/vibration/notification
        AlarmServiceHolder.ringtone?.stop()
        AlarmServiceHolder.vibrator?.cancel()
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(NOTIFICATION_ID)

        // Reschedule the alarm 1 minute ahead
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val triggerAtMillis = System.currentTimeMillis() + 60_000

        val snoozeIntent = Intent(context, AlarmBroadcastReceiver::class.java).apply {
            putExtra("alarmId", alarmId)
            putExtra("hour", hour)
            putExtra("minute", minute)
            putExtra("isSnoozed", true)
            action = "com.ccextractor.uac_companion.ALARM_TRIGGERED_$alarmId"
        }
        
        val snoozePendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId, // Same ID, reused for snooze
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