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
import com.ccextractor.uac_companion.AlarmScheduler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
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
    private val PATH_FOR_SMART_CONTOLS_VERDICTS = "/uac/pre_check_verdict"

    companion object {
        var flutterEngine: FlutterEngine? = null
        val mainThreadHandler = Handler(Looper.getMainLooper())
        const val CHANNEL_NAME = "uac_alarm_channel"
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "🟢 Watch UACDataLayerListenerService created and alive")
    }

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        Log.d(TAG, "📡 Watch DataLayerService triggered")

        for (event in dataEvents) {
            if (event.type != DataEvent.TYPE_CHANGED) continue

            val item = event.dataItem
            val path = item.uri.path ?: continue
            val dataMap = DataMapItem.fromDataItem(item).dataMap

            when {
                //! Alarm receiving PATH
                path == PATH_ALARM_PHONE_TO_WATCH -> {
                    val alarmJsonRaw = dataMap.getString("alarm_json")
                    if (alarmJsonRaw != null) {
                        Log.d(TAG, "Received alarm data from phone.")
                        AlarmDBService(this).insertAlarmFromJson(this, alarmJsonRaw)
                        AlarmScheduler.scheduleNextAlarm(this)
                        
                        notifyFlutterOfAlarmChange()
                    }
                }

                //! Action receiving path
                path == PATH_ACTION_PHONE_TO_WATCH -> {
                    val action = dataMap.getString("action")
                    val uniqueSyncId = dataMap.getString("alarm_id") ?: ""

                    if (action == null) {
                        Log.w(TAG, "Received null action from phone.")
                        continue
                    }

                    Log.d(TAG, "Received action from phone: '$action' for uniqueSyncId: $uniqueSyncId")

                    when (action) {
                        "delete alarm" -> deleteAlarm(uniqueSyncId)
                        "dismiss" -> {
                            val intent = Intent(applicationContext, AlarmDismissReceiver::class.java).apply {
                                putExtra("alarmId", uniqueSyncId)
                                putExtra("fromPhone", true)
                            }
                            sendBroadcast(intent)
                        }
                        "snooze" -> {
                            val intent = Intent(applicationContext, AlarmSnoozeReceiver::class.java).apply{
                                putExtra("alarmId", uniqueSyncId)
                                putExtra("fromPhone", true)
                            }
                            sendBroadcast(intent)
                        }
                    }
                }

                path == PATH_FOR_SMART_CONTOLS_VERDICTS -> {
                    val alarmId = dataMap.getString("alarmID")
                    val willRing = dataMap.getBoolean("willRing", true)
                    val reason = dataMap.getString("reason")
    
                    Log.d(TAG, "Verdict received for alarm $alarmId: willRing=$willRing, Reason: $reason")
    
                    if (alarmId != null && !willRing) {
                        Log.i(TAG, "Verdict is 'Don't Ring'. Attempting to cancel scheduled alarm on watch for ID: $alarmId")
                        
                        CoroutineScope(Dispatchers.IO).launch {
                            cancelScheduledAlarm(alarmId)
                        }
                    }
                }
            }
        }
        dataEvents.release()
    }

    private fun cancelScheduledAlarm(uniqueSyncId: String) {
        AlarmScheduler.cancelAlarm(applicationContext, uniqueSyncId)
        Log.d(TAG, "Called AlarmScheduler.cancelAlarm for uniqueSyncId: $uniqueSyncId")
    }

    private fun deleteAlarm(uniqueSyncId: String) {
        if (uniqueSyncId.isEmpty()) {
            Log.w(TAG, "Cannot delete alarm, uniqueSyncId is empty.")
            return
        }

        Log.d(TAG, "Attempting to delete alarm with uniqueSyncId: $uniqueSyncId")
        
        CoroutineScope(Dispatchers.IO).launch {
            val dbService = AlarmDBService(applicationContext)
            val rowsDeleted = dbService.deleteAlarm(uniqueSyncId)
            
            withContext(Dispatchers.Main) {
                if (rowsDeleted > 0) {
                    Log.d(TAG, "✅ Successfully deleted alarm from the watch database.")
                    AlarmScheduler.scheduleNextAlarm(applicationContext)
                    notifyFlutterOfAlarmChange()
                } else {
                    Log.w(TAG, "⚠️ No alarm found with uniqueSyncId '$uniqueSyncId' to delete.")
                }
            }
        }
    }

    private fun notifyFlutterOfAlarmChange() {
        mainThreadHandler.post {
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                Log.d(TAG, "🚀 Sending 'alarmsChanged' event to Flutter on the watch.")
                MethodChannel(messenger, CHANNEL_NAME).invokeMethod("alarmsChanged", null)
            } ?: Log.w(TAG, "Could not notify Flutter: flutterEngine or messenger is null.")
        }
    }
}