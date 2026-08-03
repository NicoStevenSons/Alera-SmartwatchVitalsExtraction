package com.alera.payloadextraction.health

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

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

    suspend fun readTodayStepSessions(): List<StepSession> {
        val zoneId = ZoneId.systemDefault()

        val startOfToday =
            LocalDate.now(zoneId)
                .atStartOfDay(zoneId)
                .toInstant()

        val now = Instant.now()

        val response =
            healthConnectClient.readRecords(
                ReadRecordsRequest(
                    recordType = StepsRecord::class,
                    timeRangeFilter =
                        TimeRangeFilter.between(
                            startOfToday,
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