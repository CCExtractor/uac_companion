package com.example.uac_companion

import android.app.*
import android.content.*
import android.media.*
import android.net.Uri
import android.os.*
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmBroadcastReceiver : BroadcastReceiver() {

    private val CHANNEL_ID = "alarm_channel_id"

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmReceiver", "Alarm triggered!")

        val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Alarm Channel"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel =
                    NotificationChannel(CHANNEL_ID, name, importance).apply {
                        description = "Channel for alarm notifications"
                        enableVibration(true)
                        vibrationPattern = longArrayOf(0, 1000, 500, 1000)
                        setSound(
                                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM),
                                AudioAttributes.Builder()
                                        .setUsage(AudioAttributes.USAGE_ALARM)
                                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                        .build()
                        )
                    }
            notificationManager.createNotificationChannel(channel)
        }

        val alarmSound: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        val ringtone = RingtoneManager.getRingtone(context, alarmSound)
        ringtone.isLooping = true
        ringtone.play()

        // ! Might need to change the Vibrations_service to use the new API
        val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        val vibrationPattern = longArrayOf(0, 1000, 500, 1000)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(vibrationPattern, 0))
        } else {
            @Suppress("DEPRECATION") vibrator.vibrate(vibrationPattern, 0)
        }

        AlarmServiceHolder.ringtone = ringtone
        AlarmServiceHolder.vibrator = vibrator

        val dismissIntent = Intent(context, AlarmDismissReceiver::class.java)
        val dismissPendingIntent =
                PendingIntent.getBroadcast(
                        context,
                        0,
                        dismissIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                val snoozeIntent = Intent(context, AlarmSnoozeReceiver::class.java)
                val snoozePendingIntent = PendingIntent.getBroadcast(
                    context, 1, snoozeIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
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
    }
}
