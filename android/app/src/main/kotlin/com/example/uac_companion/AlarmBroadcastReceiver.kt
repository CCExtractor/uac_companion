package com.ccextractor.uac_companion

import android.app.*
import android.content.*
import android.media.*
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat
import com.ccextractor.uac_companion.data.AlarmDbModel

object AlarmServiceHolder {
    var ringtone: Ringtone? = null
    var vibrator: Vibrator? = null
}

class AlarmBroadcastReceiver : BroadcastReceiver() {

    companion object {
        private const val CHANNEL_ID = "uac_alarm_channel_id"
        private const val NOTIFICATION_ID = 1001
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmBroadcastReceiver", "Alarm triggered!")

        val alarmId = intent.getIntExtra("alarmId", -1)
        val hour = intent.getIntExtra("hour", 0)
        val minute = intent.getIntExtra("minute", 0)

        // Disable one-time alarm directly
        if (intent.getStringExtra("days").isNullOrEmpty()) {
            val db = AlarmDbModel(context).writableDatabase
            db.execSQL("UPDATE alarms SET enabled = 0 WHERE id = ?", arrayOf(alarmId.toString()))
            db.close()
            Log.d("AlarmBroadcastReceiver", "Disabled one-time alarm ID=$alarmId")
        }

        val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Create notification channel (safe to call multiple times)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel =
                    NotificationChannel(
                            CHANNEL_ID,
                            "Alarm Channel",
                            NotificationManager.IMPORTANCE_HIGH
                    )
            channel.description = "Channel for alarm notifications"
            channel.enableVibration(true)
            channel.vibrationPattern = longArrayOf(0, 1000, 500, 1000)
            notificationManager.createNotificationChannel(channel)
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
                } catch (e: Exception) {
                    Log.e("AlarmBroadcastReceiver", "Error playing ringtone", e)
                }
            }
        }

        // Vibrate
        val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        val pattern = longArrayOf(0, 1000, 500, 1000)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION") vibrator.vibrate(pattern, 0)
        }
        AlarmServiceHolder.vibrator = vibrator

        // Dismiss Intent
        val dismissIntent =
                Intent(context, AlarmDismissReceiver::class.java).apply {
                    action = "com.ccextractor.uac_companion.ALARM_DISMISS_$alarmId"
                    putExtra("alarmId", alarmId)
                }
        val dismissPendingIntent =
                PendingIntent.getBroadcast(
                        context,
                        alarmId,
                        dismissIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

        // Snooze Intent
        val snoozeIntent =
                Intent(context, AlarmSnoozeReceiver::class.java).apply {
                    putExtra("alarmId", alarmId)
                    putExtra("hour", hour)
                    putExtra("minute", minute)
                }
        val snoozePendingIntent =
                PendingIntent.getBroadcast(
                        context,
                        alarmId,
                        snoozeIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

        // Notification
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

        // Schedule next upcoming alarm
        AlarmScheduler.scheduleNextAlarm(context)
        Log.d("AlarmBroadcastReceiver", "Scheduled next upcoming alarm after trigger")
    }
}
