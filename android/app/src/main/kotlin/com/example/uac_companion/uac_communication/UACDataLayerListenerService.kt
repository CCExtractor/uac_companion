package com.ccextractor.uac_companion.communication

import android.content.Context
import android.content.Intent
import android.util.Log
import com.google.android.gms.wearable.*
import com.google.android.gms.wearable.WearableListenerService
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import android.os.Handler
import android.os.Looper
// import com.ccextractor.uac_companion.communication.data.AlarmModelReceived
import com.ccextractor.uac_companion.AlarmScheduler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import com.google.android.gms.wearable.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import com.ccextractor.uac_companion.data.AlarmDBService
import com.ccextractor.uac_companion.AlarmDismissReceiver
import com.ccextractor.uac_companion.AlarmSnoozeReceiver

class UACDataLayerListenerService : WearableListenerService() {
    private val TAG = "UACDataLayerListenerService"
    private val PATH_ACTION_PHONE_TO_WATCH = "/uac_phone_to_watch/action"
    private val PATH_ALARM_PHONE_TO_WATCH = "/uac_phone_to_watch/alarm"

    companion object {
        var flutterEngine: FlutterEngine? = null
        val mainThreadHandler = Handler(Looper.getMainLooper())
        const val CHANNEL_NAME = "uac_alarm_channel"
    }    

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🟢 Watch UACDataLayerListenerService created and alive")    }

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        Log.d(TAG, "📡 Watch DataLayerService triggered")

        for (event in dataEvents) {
            if (event.type != DataEvent.TYPE_CHANGED) continue

            val item = event.dataItem
            val path = item.uri.path ?: continue
            val dataMap = DataMapItem.fromDataItem(item).dataMap

            Log.d(TAG, "➡ Path: $path | Data keys: ${dataMap.keySet()}")

            when {
                //! Alarm receiving PATH
                path == PATH_ALARM_PHONE_TO_WATCH -> {
                    val alarmJsonRaw = dataMap.getString("alarm_json")
                    val uniqueSyncId = dataMap.getString("uniqueSyncId")
                    Log.d(TAG, "Received alarm_json from phone: $alarmJsonRaw, for uniqueSyncId: $uniqueSyncId")
                    if (alarmJsonRaw != null) {
                        // AlarmDbHelper().insertAlarmFromJson(this, alarmJsonRaw)
                        AlarmDBService(this).insertAlarmFromJson(this, alarmJsonRaw)
                        AlarmScheduler.scheduleNextAlarm(this)
                        notifyFlutterOfAlarmInsert()
                    }
                }

                //! Action receiving path
                path == PATH_ACTION_PHONE_TO_WATCH -> {
                    val action = dataMap.getString("action")
                    val alarmId = dataMap.getInt("alarm_id", -1)
                    val uniqueSyncId = dataMap.getString("uniqueSyncId") ?: ""
                    val timestamp = dataMap.getLong("timestamp", -1L)

                    if (action == null) {
                        Log.w(TAG, "Received null action from phone.")
                        continue
                    }

                    Log.d(TAG, "Received action from phone: '$action' for alarm ID: $alarmId")

                    if (action == "dismiss") {
                        val intent = Intent(applicationContext, AlarmDismissReceiver::class.java).apply {
                            putExtra("alarmId", alarmId)
                            putExtra("fromPhone", true)
                            putExtra("uniqueSyncId", uniqueSyncId)
                        }
                        sendBroadcast(intent)
                    }

                    if(action == "snooze") {
                        val intent = Intent(applicationContext, AlarmSnoozeReceiver::class.java).apply{
                            putExtra("alarmId", alarmId)
                            putExtra("uniqueSyncId", uniqueSyncId)
                            putExtra("fromPhone", true)
                        }
                        sendBroadcast(intent)
                    }
                }

                else -> {
                    if (path.startsWith("/uac_fallback/")) {
                        val action = dataMap.getString("action")
                        val timestamp = dataMap.getLong("timestamp")
                        if (action == null || timestamp == 0L) {
                            Log.w(TAG, "Skipping stale fallback event: action=$action, timestamp=$timestamp")
                        } else {
                            Log.d(TAG, "Fallback received: action=$action at $timestamp")
                        }
                    }
                }
            }
        }
        dataEvents.release()
    }
}