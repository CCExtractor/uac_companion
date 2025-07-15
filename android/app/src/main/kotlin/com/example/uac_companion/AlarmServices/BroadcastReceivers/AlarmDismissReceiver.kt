package com.ccextractor.uac_companion

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationManagerCompat
import com.ccextractor.uac_companion.communication.WatchAlarmSender

class AlarmDismissReceiver : BroadcastReceiver() {
    final val TAG = "AlarmDismissReceiver"
    override fun onReceive(context: Context, intent: Intent?) {
        WatchAlarmSender.sendActionToPhone(context, "dismiss")

        AlarmServiceHolder.ringtone?.let { ringtone ->
            if (ringtone.isPlaying) {
                ringtone.stop()
                Log.d(TAG, "Ringtone stopped")
            }
            AlarmServiceHolder.ringtone = null
        }

        AlarmServiceHolder.vibrator?.let { vibrator ->
            vibrator.cancel()
            Log.d(TAG, "Vibration cancelled")
            AlarmServiceHolder.vibrator = null
        }

        NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
        Log.d(TAG, "Notification cancelled")
    }
}