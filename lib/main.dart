import 'package:flutter/material.dart';

import 'Services/watch_payload_service.dart';
import 'Services/health_event_api_service.dart';
import 'Services/health_event_mapper.dart';

import 'config/app_config.dart';

import 'dart:convert';

import 'models/heart_rate_data.dart';
import 'models/spo2_data.dart';
import 'models/steps_data.dart';
import 'models/device_status_data.dart';

import 'widgets/device_status_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final WatchPayloadService watchPayloadService = WatchPayloadService();

  final HealthEventApiService healthEventApiService =
    HealthEventApiService(
  baseUrl: AppConfig.backendBaseUrl,
  patientId: AppConfig.testPatientId,
);

  HeartRateData heartRateData = const HeartRateData(bpm: null, status: null, measuredAt: null,);
  SpO2Data spo2Data = SpO2Data.empty();
  StepsData stepsData = StepsData.empty();
  DeviceStatusData deviceStatusData = DeviceStatusData.empty();

  @override
  void initState() {
    super.initState();

    watchPayloadService.startListening(
      onHeartRateReceived: (HeartRateData data) {
  if (!mounted) {
    return;
  }

  setState(() {
    heartRateData = data;
  });

  final int? bpm = data.bpm;
  final String? measuredAt = data.measuredAt;

  if (bpm == null || measuredAt == null) {
    debugPrint(
      'Heart-rate reading not sent: '
      'missing BPM or timestamp.',
    );
    return;
  }

  final Map<String, dynamic> backendPayload =
      HealthEventMapper.mapHeartRate(
    patientId: healthEventApiService.patientId,
    heartRateBpm: bpm,
    recordedAt: measuredAt,
    rawPayload: data.toJson(),
  );

  if (AppConfig.enableBackend) {
  healthEventApiService.sendHealthEvent(
    backendPayload,
  );
} else {
  debugPrint(
    'Mapped HR backend payload: '
    '${jsonEncode(backendPayload)}',
  );
}
},
      
    onSpO2Received: (SpO2Data data) {
  if (!mounted) {
    return;
  }

  setState(() {
    spo2Data = data;
  });

  final double? percent = data.percent;
  final String? measuredAt = data.measuredAt;

  if (percent == null || measuredAt == null) {
    debugPrint(
      'SpO₂ reading not sent: '
      'missing percentage or timestamp.',
    );
    return;
  }

  final Map<String, dynamic> backendPayload =
      HealthEventMapper.mapSpO2(
    patientId: healthEventApiService.patientId,
    spo2Percent: percent,
    recordedAt: measuredAt,
    rawPayload: data.toJson(),
  );

  if (AppConfig.enableBackend) {
  healthEventApiService.sendHealthEvent(
    backendPayload,
  );
} else {
  debugPrint(
    'Mapped SpO₂ backend payload: '
    '${jsonEncode(backendPayload)}',
  );
}
},

    onStepsReceived: (StepsData data) {
  if (!mounted) {
    return;
  }

  setState(() {
    stepsData = data;
      });
    },

    onDeviceStatusReceived: (
  DeviceStatusData data,
) {
  if (!mounted) {
    return;
  }

  setState(() {
    deviceStatusData = data;
  });
},

    //spaceforSleepa

     onError: (Object error) {
      debugPrint(
        'Payload listener error: $error',
      );
    },

    );
  }


  @override
  void dispose() {
    watchPayloadService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.purple,
              title: const Text('Alera'),
              actions: [
                Padding(padding: const EdgeInsetsGeometry.only(right: 12)
                ),
                IconButton(icon: Icon(deviceStatusData.connectedToPhone ? Icons.watch : Icons.watch_off,), 
                onPressed:(){
                  showDeviceStatusDialog(
                  context: context,
                  deviceStatusData: deviceStatusData,
                  );
                }
                )
              ],//Actions
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
          
                children: [
          Row(//HeartRatePayload
                    children: [
                      const Icon(Icons.favorite,
                                  color: Colors.red,
                                    ),
                      Text('Heart Rate: ''${heartRateData.displayedHeartRate} BPM',),
                    ],
                  ),
                  Text(heartRateData.displayedStatus),
                  Text(heartRateData.measuredAt ?? 'No measurement received',),
                  const SizedBox(height: 16),
          
          Row(//spo2DataPayload
                    children: [
                      const Icon(Icons.bloodtype,
                                  color: Colors.red,
                                    ),
                      Text('SpO2: ''${spo2Data.displayedPercent}%',),
                      
                    ],
                  ),
                  Text(spo2Data.displayedStatus),
                  Text(spo2Data.measuredAt ?? 'No measurement received',),
                  const SizedBox(height: 16),
          
          Row(//Steps
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.stairs),
              Text(
          'Total Steps: ${stepsData.displayedTotalSteps}',
              ),
              Column(
          children: [
              Text(
          'Sessions: ${stepsData.sessions.length}',
              ),
          
              if (stepsData.sessions.isEmpty)
          const Text(
            'No step sessions received',
          ),
          
              ...stepsData.sessions.map(
          (StepSessionData session) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 28,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.stairs,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${session.stepCount} steps\n'
                      'Start: ${session.startTime}\n'
                      'End: ${session.endTime}',
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ]
              )
                
               
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}