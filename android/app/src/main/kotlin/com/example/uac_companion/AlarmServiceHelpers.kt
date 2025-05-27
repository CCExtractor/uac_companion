package com.example.uac_companion

import android.media.Ringtone
import android.os.Vibrator

const val NOTIFICATION_ID = 1001

object AlarmServiceHolder {
    var ringtone: Ringtone? = null
    var vibrator: Vibrator? = null
}
