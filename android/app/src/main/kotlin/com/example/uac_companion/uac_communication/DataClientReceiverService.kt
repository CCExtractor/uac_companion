package com.ccextractor.uac_companion.communication

import android.util.Log
import com.google.android.gms.wearable.*
import com.google.android.gms.wearable.WearableListenerService
import com.google.android.gms.wearable.DataMapItem

class DataClientReceiverService : WearableListenerService() {
    private val TAG = "UAC_DataClientReceiverService"

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        // Log.d(TAG, "onDataChanged triggered (Service)")

        for (event in dataEvents) {
            val path = event.dataItem.uri.path ?: continue
            val dataMap = DataMapItem.fromDataItem(event.dataItem).dataMap
            val action = dataMap.getString("action")
            val timestamp = dataMap.getLong("timestamp")

            if (action == null || timestamp == 0L) {
                Log.w(TAG, "Skipping stale fallback event: action=$action, timestamp=$timestamp")
                continue
            }

            Log.d(TAG, "Fallback received: action=$action at $timestamp")
        }

        dataEvents.release()
    }
}