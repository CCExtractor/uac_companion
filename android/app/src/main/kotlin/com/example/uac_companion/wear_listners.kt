package com.example.uac_companion

import android.content.Context
import android.util.Log
import android.net.Uri
import com.google.android.gms.wearable.*
import io.flutter.plugin.common.EventChannel

class WearListeners(
    private val context: Context,
    private val eventSink: EventChannel.EventSink
) : MessageClient.OnMessageReceivedListener,
    DataClient.OnDataChangedListener,
    CapabilityClient.OnCapabilityChangedListener {

    init {
        Wearable.getMessageClient(context).addListener(this)
        Wearable.getDataClient(context).addListener(this)
        Wearable.getCapabilityClient(context)
            .addListener(this, Uri.EMPTY, CapabilityClient.FILTER_ALL)
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        val path = messageEvent.path
        val data = String(messageEvent.data)
        Log.d("WearListeners", "Message received: $data")
    
        if (path == "/APP_OPEN_WEARABLE_PAYLOAD") {
            val ack = "AppOpenWearableACK".toByteArray()
            Wearable.getMessageClient(context).sendMessage(
                messageEvent.sourceNodeId, path, ack
            )
            Log.d("WearListeners", "ACK sent back to phone")
        }
    
        eventSink?.success(mapOf(
            "type" to "message",
            "path" to path,
            "data" to data
        ))
    }
    

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        for (event in dataEvents) {
            if (event.type == DataEvent.TYPE_CHANGED) {
                val dataMap = DataMapItem.fromDataItem(event.dataItem).dataMap
                val interval = dataMap.getLong("interval", -1L)

                eventSink.success(mapOf(
                    "type" to "data",
                    "path" to event.dataItem.uri.path,
                    "interval" to interval
                ))
            }
        }
    }

    override fun onCapabilityChanged(capabilityInfo: CapabilityInfo) {
        eventSink.success(mapOf(
            "type" to "capability",
            "name" to capabilityInfo.name
        ))
    }
}