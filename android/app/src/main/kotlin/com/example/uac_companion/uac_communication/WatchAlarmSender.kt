package com.ccextractor.uac_companion.communication

import android.content.Context
import android.util.Log
import com.ccextractor.uac_companion.data.Alarm
import com.google.android.gms.wearable.*
import com.google.gson.Gson

object WatchAlarmSender {
    private const val TAG = "UAC_WatchSender"
    private val PATH_ACTION_WATCH_TO_PHONE = "/uac_watch_to_phone/action"
    private val PATH_ALARM_WATCH_TO_PHONE = "/uac_watch_to_phone/alarm"

    fun sendAlarmToPhone(context: Context, alarm: Alarm) {
        val alarmJson = Gson().toJson(alarm)
        Log.d(TAG, "Preparing to send alarm with id=${alarm.id}")
        sendAlarmToPhone(context, alarmJson)
    }

    fun sendAlarmToPhone(context: Context, alarmJson: String) {
        val timestamp = System.currentTimeMillis()

        Log.d(TAG, "Sending alarm block to phone: $alarmJson")

        val putDataMapRequest = PutDataMapRequest.create(PATH_ALARM_WATCH_TO_PHONE)
        val dataMap = putDataMapRequest.dataMap

        // dataMap.putString("alarm_id", alarmId)
        dataMap.putString("alarm_json", alarmJson)
        dataMap.putLong("timestamp", timestamp)

        val request = putDataMapRequest.asPutDataRequest().setUrgent()

        Wearable.getDataClient(context)
                .putDataItem(request)
                .addOnSuccessListener { Log.d(TAG, "Alarm sent via DataClient: $alarmJson") }
                .addOnFailureListener { e -> Log.e(TAG, "Alarm sync failed via DataClient", e) }
    }

    fun sendActionToPhone(context: Context, action: String, uniqueSyncId: String, id: Int) {
        val timestamp = System.currentTimeMillis()
        // val path = PATH_ALARM_WATCH_TO_PHONE
    
        Log.d(TAG, "Sending action to phone: $action for id: $id for uniqueSyncId: $uniqueSyncId")
    
        val putDataMapRequest = PutDataMapRequest.create(PATH_ACTION_WATCH_TO_PHONE)
        val dataMap = putDataMapRequest.dataMap
    
        // FIX: match keys used on receiving side
        dataMap.putString("action", action)
        dataMap.putString("uniqueSyncId", uniqueSyncId)
        dataMap.putInt("id", id)
        dataMap.putLong("timestamp", timestamp)
    
        val request = putDataMapRequest.asPutDataRequest().setUrgent()
    
        Wearable.getDataClient(context)
            .putDataItem(request)
            .addOnSuccessListener { Log.d(TAG, "Action sent via DataClient: $action") }
            .addOnFailureListener { e -> Log.e(TAG, "Action send failed via DataClient", e) }
    }    
}
