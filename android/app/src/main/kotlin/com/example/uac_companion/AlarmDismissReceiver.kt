package com.example.uac_companion

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationManagerCompat

class AlarmDismissReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        Log.d("AlarmDismissReceiver", "Dismiss action received")

        // Stop the ringtone if playing
        AlarmServiceHolder.ringtone?.let {
            if (it.isPlaying) {
                it.stop()
                Log.d("AlarmDismissReceiver", "Ringtone stopped")
            } else {
                Log.d("AlarmDismissReceiver", "Ringtone was not playing")
            }

            // Post-check if still playing
            Log.d("AlarmDismissReceiver", "Post-check: isPlaying = ${it.isPlaying}")
            AlarmServiceHolder.ringtone = null
        } ?: Log.d("AlarmDismissReceiver", "No ringtone to stop")

        // Cancel vibration
        AlarmServiceHolder.vibrator?.let {
            it.cancel()
            Log.d("AlarmDismissReceiver", "Vibration cancelled")

            Log.d("AlarmDismissReceiver", "Post-check: vibrator ref will be nullified")
            AlarmServiceHolder.vibrator = null
        } ?: Log.d("AlarmDismissReceiver", "No vibrator to cancel")

        // Dismiss the notification
        NotificationManagerCompat.from(context).cancel(AlarmBroadcastReceiver.NOTIFICATION_ID)
        Log.d("AlarmDismissReceiver", "Notification dismissed")
    }
}
