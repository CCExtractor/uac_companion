package com.ccextractor.uac_companion.communication

import android.content.Context
import android.util.Log
import com.ccextractor.uac_companion.data.Alarm
import com.google.android.gms.wearable.*
import com.google.gson.Gson

object WatchAlarmSender {
    private const val TAG = "UAC_WatchSender"
    private const val PATH = "/uac_alarm_sync/alarm"

    fun sendAlarmToPhone(context: Context, alarm: Alarm) {
        val alarmJson = Gson().toJson(alarm)
        sendAlarmToPhone(context, alarmJson)
    }

    fun sendAlarmToPhone(context: Context, alarmJson: String) {
        val timestamp = System.currentTimeMillis()

        Log.d(TAG, "Sending alarm block to phone: $alarmJson")

        val putDataMapRequest = PutDataMapRequest.create(PATH)
        val dataMap = putDataMapRequest.dataMap

        dataMap.putString("alarm_json", alarmJson)
        dataMap.putLong("timestamp", timestamp)

        val request = putDataMapRequest.asPutDataRequest().setUrgent()

        Wearable.getDataClient(context)
                .putDataItem(request)
                .addOnSuccessListener { Log.d(TAG, "Alarm sync sent via DataClient: $alarmJson") }
                .addOnFailureListener { e -> Log.e(TAG, "Alarm sync failed via DataClient", e) }
    }

    fun sendActionToPhone(context: Context, action: String) {
        val timestamp = System.currentTimeMillis()
        val path = "/uac_alarm_sync/action"

        Log.d(TAG, "Sending action to phone: $action")

        val putDataMapRequest = PutDataMapRequest.create(path)
        val dataMap = putDataMapRequest.dataMap

        dataMap.putString("alarm_json", action)
        dataMap.putLong("timestamp", timestamp)

        val request = putDataMapRequest.asPutDataRequest().setUrgent()

        Wearable.getDataClient(context)
                .putDataItem(request)
                .addOnSuccessListener { Log.d(TAG, "Action sent via DataClient: $action") }
                .addOnFailureListener { e -> Log.e(TAG, "Action send failed via DataClient", e) }
    }
}
