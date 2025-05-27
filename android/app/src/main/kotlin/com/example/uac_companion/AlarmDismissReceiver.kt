package com.example.uac_companion

import android.app.NotificationManager
import android.content.*
import android.util.Log

class AlarmDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmDismissReceiver", "Alarm dismissed.")

        AlarmServiceHolder.ringtone?.stop()
        AlarmServiceHolder.vibrator?.cancel()

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(NOTIFICATION_ID)
    }
}

