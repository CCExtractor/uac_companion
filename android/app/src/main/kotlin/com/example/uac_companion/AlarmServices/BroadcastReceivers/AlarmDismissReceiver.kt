package com.ccextractor.uac_companion

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationManagerCompat
import com.ccextractor.uac_companion.NOTIFICATION_ID

class AlarmDismissReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        AlarmServiceHolder.ringtone?.let { ringtone ->
            if (ringtone.isPlaying) {
                ringtone.stop()
                Log.d("UAC_Comp-AlarmDismissReceiver", "Ringtone stopped")
            }
            AlarmServiceHolder.ringtone = null
        }

        AlarmServiceHolder.vibrator?.let { vibrator ->
            vibrator.cancel()
            Log.d("UAC_Comp-AlarmDismissReceiver", "Vibration cancelled")
            AlarmServiceHolder.vibrator = null
        }

        NotificationManagerCompat.from(context).cancel(NOTIFICATION_ID)
        Log.d("UAC_Comp-AlarmDismissReceiver", "Notification cancelled")
    }
}
