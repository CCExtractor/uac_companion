package com.example.uac_companion

import android.app.*
import android.content.*
import android.media.*
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.android.gms.wearable.R
import com.example.uac_companion.NOTIFICATION_ID

object AlarmServiceHolder {
    var ringtone: Ringtone? = null
    var vibrator: Vibrator? = null
}

class AlarmBroadcastReceiver : BroadcastReceiver() {

    companion object {
        private const val CHANNEL_ID = "alarm_channel_id"
        // const val NOTIFICATION_ID = 1001
        private var channelCreated = false
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmReceiver", "Alarm triggered!")
        val alarmId = intent.getIntExtra("alarmId", -1)
        Log.d("AlarmBroadcastReceiver", "Showing notification for alarmId: $alarmId")

        val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Notification channel
        if (!channelCreated && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Alarm Channel"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel =
                    NotificationChannel(CHANNEL_ID, name, importance).apply {
                        description = "Channel for alarm notifications"
                        enableVibration(true)
                        vibrationPattern = longArrayOf(0, 1000, 500, 1000)
                    }
            notificationManager.createNotificationChannel(channel)
            channelCreated = true
            Log.d("AlarmReceiver", "Notification channel created")
        }

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

        val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        val vibrationPattern = longArrayOf(0, 1000, 500, 1000)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(vibrationPattern, 0))
            Log.d("AlarmReceiver", "Vibration started (vibrationEffect)")
        } else {
            @Suppress("DEPRECATION") vibrator.vibrate(vibrationPattern, 0)
            Log.d("AlarmReceiver", "Vibration started (deprecated vibrate)")
        }
        AlarmServiceHolder.vibrator = vibrator

        val dismissIntent =
                Intent(context, AlarmDismissReceiver::class.java).apply {
                    action = "com.yourpackage.ALARM_DISMISS_$alarmId"
                    putExtra("alarmId", alarmId)
                }
        val dismissPendingIntent =
                PendingIntent.getBroadcast(
                        context,
                        alarmId,
                        dismissIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

        val snoozeIntent = Intent(context, AlarmSnoozeReceiver::class.java).apply {
            action = "com.yourpackage.ALARM_SNOOZE_$alarmId"
            putExtra("alarmId", alarmId)
        }
        val snoozePendingIntent =
                PendingIntent.getBroadcast(
                        context,
                        1,
                        snoozeIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

        // Build notification
        val notification =
                NotificationCompat.Builder(context, CHANNEL_ID)
                        .setContentTitle("Alarm Alert")
                        .setContentText("Alarm is ringing")
                        .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setCategory(NotificationCompat.CATEGORY_ALARM)
                        .setOngoing(true)
                        .addAction(
                                android.R.drawable.ic_media_pause,
                                "Dismiss",
                                dismissPendingIntent
                        )
                        .addAction(android.R.drawable.ic_media_play, "Snooze", snoozePendingIntent)
                        .setFullScreenIntent(dismissPendingIntent, true)
                        .build()

        notificationManager.notify(NOTIFICATION_ID, notification)
    }
}
