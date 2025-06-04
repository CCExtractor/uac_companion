package com.example.uac_companion

import android.app.NotificationManager
import android.app.PendingIntent
import android.app.AlarmManager
import android.content.*
import android.util.Log
import android.os.Build
import java.sql.Date

class AlarmSnoozeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmSnoozeReceiver", "Snoozing alarm...")
    
        // Cancel current notification and alarm
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(NOTIFICATION_ID)
    
        AlarmServiceHolder.ringtone?.stop()
        AlarmServiceHolder.vibrator?.cancel()
    
        // Reschedule alarm after 1 minutes
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val newIntent = Intent(context, AlarmBroadcastReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            //! doubt
            999, // Unique snooze ID or original alarm ID
            newIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    
        val triggerAt = System.currentTimeMillis() + 1 * 60 * 1000
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
        }
    
        Log.d("AlarmSnoozeReceiver", "Alarm snoozed to $triggerAt}")
    }
    
}