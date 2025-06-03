package com.example.uac_companion

import android.content.Context
import android.media.RingtoneManager
import android.media.Ringtone
import android.net.Uri
import android.util.Log

object RingtoneHandler {
    private var ringtone: Ringtone? = null

    fun playRingtone(context: Context) {
        val uri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
        ringtone = RingtoneManager.getRingtone(context, uri)
        ringtone?.play()
        Log.d("RingtoneHandler", "Ringtone started")
    }

    fun stopRingtone() {
        if (ringtone?.isPlaying == true) {
            ringtone?.stop()
            Log.d("RingtoneHandler", "Ringtone stopped")
        } else {
            Log.d("RingtoneHandler", "Ringtone was not playing")
        }
        ringtone = null
    }

    fun isRingtonePlaying(): Boolean {
        val playing = ringtone?.isPlaying == true
        Log.d("RingtoneHandler", "isRingtonePlaying: $playing")
        return playing
    }
}
