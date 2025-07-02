package com.ccextractor.uac_companion

import android.app.*
import android.content.*
import android.icu.util.Calendar
import android.media.*
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import com.ccextractor.uac_companion.AlarmDismissReceiver

object AlarmServiceHolder {
    var ringtone: Ringtone? = null
    var vibrator: Vibrator? = null
}

class AlarmBroadcastReceiver : BroadcastReceiver() {

    companion object {
        private const val CHANNEL_ID = "uac_alarm_channel_id"
        private const val NOTIFICATION_ID = 1001
        private var channelCreated = false
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmReceiver", "Alarm triggered!")
        val alarmId = intent.getIntExtra("alarmId", -1)
        val hour = intent.getIntExtra("hour", 0)
        val minute = intent.getIntExtra("minute", 0)
        Log.d("AlarmBroadcastReceiver", "Showing notification for alarmId: $alarmId")

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create notification channel if not created
        if (!channelCreated && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Alarm Channel",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Channel for alarm notifications"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 1000, 500, 1000)
            }
            notificationManager.createNotificationChannel(channel)
            channelCreated = true
        }

        // Play ringtone
        val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        if (AlarmServiceHolder.ringtone == null) {
            AlarmServiceHolder.ringtone = RingtoneManager.getRingtone(context, alarmUri)
        }
        AlarmServiceHolder.ringtone?.let {
            if (!it.isPlaying) {
                try {
                    it.play()
                    Log.d("AlarmReceiver", "Ringtone started")
                } catch (e: Exception) {
                    Log.e("AlarmReceiver", "Error playing ringtone", e)
                }
            }
        }

        // Vibrate
        val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        val vibrationPattern = longArrayOf(0, 1000, 500, 1000)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(vibrationPattern, 0))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(vibrationPattern, 0)
        }
        AlarmServiceHolder.vibrator = vibrator

        // Dismiss and snooze actions
        val dismissIntent = Intent(context, AlarmDismissReceiver::class.java).apply {
            action = "com.yourpackage.ALARM_DISMISS_$alarmId"
            putExtra("alarmId", alarmId)
        }
        val dismissPendingIntent = PendingIntent.getBroadcast(
            context, alarmId, dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val snoozeIntent = Intent(context, AlarmSnoozeReceiver::class.java).apply {
            putExtra("alarmId", alarmId)
            putExtra("hour", hour)
            putExtra("minute", minute)
        }
        val snoozePendingIntent = PendingIntent.getBroadcast(
            context,
            alarmId,
            snoozeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val snoozeAction = NotificationCompat.Action.Builder(
            //! look for the path
            android.R.drawable.ic_lock_idle_alarm, "Snooze", snoozePendingIntent
        ).build()
        

        // Notification
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle("Alarm Alert")
            .setContentText("Alarm is ringing")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setOngoing(true)
            .addAction(android.R.drawable.ic_media_pause, "Dismiss", dismissPendingIntent)
            .addAction(android.R.drawable.ic_media_play, "Snooze", snoozePendingIntent)
            .setFullScreenIntent(dismissPendingIntent, true)
            .build()

        notificationManager.notify(NOTIFICATION_ID, notification)

        // Reschedule repeating alarm for next week
        val calendar = Calendar.getInstance().apply {
            add(Calendar.WEEK_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            set(Calendar.DAY_OF_WEEK, Calendar.getInstance().get(Calendar.DAY_OF_WEEK))
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val pendingIntent = PendingIntent.getBroadcast(
            context, alarmId, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            calendar.timeInMillis,
            pendingIntent
        )

        Log.d("AlarmReceiver", "Rescheduled repeating alarm for next week: ${calendar.time}")
    }
}
