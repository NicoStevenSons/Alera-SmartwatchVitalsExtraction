package com.alera.payloadextraction

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

object PayloadEventBridge {
    private var eventSink: EventChannel.EventSink? = null
    private var latestPayload: String? = null

    fun attachSink(sink: EventChannel.EventSink?) {
        eventSink = sink

        latestPayload?.let { payload ->
            sendPayload(payload)
        }
    }

    fun sendPayload(payload: String) {
        latestPayload = payload

        Handler(Looper.getMainLooper()).post {
            eventSink?.success(payload)
        }
    }
}