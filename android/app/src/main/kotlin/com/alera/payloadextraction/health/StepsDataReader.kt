package com.alera.payloadextraction.health

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import java.time.Instant
import java.time.temporal.ChronoUnit

data class StepSession(
    val stepCount: Long,
    val startTime: Instant,
    val endTime: Instant
)

class StepsDataReader(
    context: Context
) {
    private val healthConnectClient =
        HealthConnectClient.getOrCreate(context)

    suspend fun readAllStepSessions():
        List<StepSession> {

        val now = Instant.now()

        val startTime =
            now.minus(
                365,
                ChronoUnit.DAYS
            )

        val response =
            healthConnectClient.readRecords(
                ReadRecordsRequest(
                    recordType =
                        StepsRecord::class,
                    timeRangeFilter =
                        TimeRangeFilter.between(
                            startTime,
                            now
                        ),
                    ascendingOrder = true
                )
            )

        return response.records.map { record ->
            StepSession(
                stepCount = record.count,
                startTime = record.startTime,
                endTime = record.endTime
            )
        }
    }
}