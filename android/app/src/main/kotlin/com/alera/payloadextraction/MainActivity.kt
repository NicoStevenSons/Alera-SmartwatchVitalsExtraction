package com.alera.payloadextraction

import android.os.Bundle
import android.util.Log
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.StepsRecord
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.launch
import com.alera.payloadextraction.health.StepsDataReader

class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val PAYLOAD_CHANNEL =
            "com.alera.payloadextraction/payloads"
    }

    private lateinit var healthConnectClient:
        HealthConnectClient

    private lateinit var stepsDataReader: StepsDataReader

    private val healthPermissions =
        setOf(
            HealthPermission.getReadPermission(
                StepsRecord::class
            )
        )

    private val healthPermissionLauncher =
    registerForActivityResult(
        PermissionController
            .createRequestPermissionResultContract()
    ) { grantedPermissions: Set<String> ->

        if (grantedPermissions.containsAll(healthPermissions)) {
            Log.d(
                "AleraHealthConnect",
                "Steps permission granted"
            )
            readAndSendTodaySteps()

        } else {
            Log.w(
                "AleraHealthConnect",
                "Steps permission denied"
            )
        }
    }

    override fun onCreate(
        savedInstanceState: Bundle?
    ) {
        super.onCreate(savedInstanceState)

        healthConnectClient =
            HealthConnectClient.getOrCreate(this)
            
            stepsDataReader =
            StepsDataReader(this)

        requestHealthPermissions()
    }

    private fun requestHealthPermissions() {
        lifecycleScope.launch {
            val grantedPermissions =
                healthConnectClient
                    .permissionController
                    .getGrantedPermissions()

            if (
                grantedPermissions.containsAll(
                    healthPermissions
                )
            ) {
                Log.d(
                    "AleraHealthConnect",
                    "Steps permission already granted"
                )

                    readAndSendTodaySteps()

            } else {
                healthPermissionLauncher.launch(
                    healthPermissions
                )
            }
        }
    }

    private fun readAndSendTodaySteps() {
    lifecycleScope.launch {
        try {
            val sessions =
                stepsDataReader.readTodayStepSessions()

            val sessionsJson =
                sessions.joinToString(
                    separator = ",",
                    prefix = "[",
                    postfix = "]"
                ) { session ->
                    """
                    {
                      "step_count": ${session.stepCount},
                      "start_time": "${session.startTime}",
                      "end_time": "${session.endTime}"
                    }
                    """.trimIndent()
                }

            val payload =
                """
                {
                  "event_type": "steps",
                  "sessions": $sessionsJson
                }
                """.trimIndent()

            Log.d(
                "AleraHealthConnect",
                "Steps payload: $payload"
            )

            PayloadEventBridge.sendPayload(payload)
        } catch (exception: Exception) {
            Log.e(
                "AleraHealthConnect",
                "Failed to read step sessions",
                exception
            )
        }
    }
}


    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(
            flutterEngine
        )

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

                    PayloadEventBridge.attachSink(
                        events
                    )
                }

                override fun onCancel(
                    arguments: Any?
                ) {
                    Log.d(
                        "AleraFlutterBridge",
                        "Flutter stopped listening"
                    )

                    PayloadEventBridge.attachSink(
                        null
                    )
                }
            }
        )
    }
}