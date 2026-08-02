package com.alera.payloadextraction

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val PAYLOAD_CHANNEL =
            "com.alera.payloadextraction/payloads"
    }

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            PAYLOAD_CHANNEL
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(
                    arguments: Any?,
                    events: EventChannel.EventSink?
                ) {
                    Log.d(
                        "AleraFlutterBridge",
                        "Flutter started listening"
                    )

                    PayloadEventBridge.attachSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    Log.d(
                        "AleraFlutterBridge",
                        "Flutter stopped listening"
                    )

                    PayloadEventBridge.attachSink(null)
                }
            }
        )
    }
}