package com.alera.payloadextraction

import android.util.Log
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService

class PhonePayloadReceiverService : WearableListenerService() {

    override fun onMessageReceived(messageEvent: MessageEvent) {
        val payloadJson =
            messageEvent.data.toString(Charsets.UTF_8)

        Log.d(
            "AleraPhoneReceiver",
            "Path: ${messageEvent.path}"
        )

        Log.d(
            "AleraPhoneReceiver",
            "Payload: $payloadJson"
        )
        
         PayloadEventBridge.sendPayload(payloadJson)
    }
}