import 'package:flutter/material.dart';

import 'models/heart_rate_data.dart';
import 'Services/watch_payload_service.dart';
import 'models/spo2_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final WatchPayloadService watchPayloadService =
      WatchPayloadService();

  HeartRateData heartRateData = const HeartRateData(
    bpm: null,
    status: null,
    measuredAt: null,
  );

  SpO2Data spo2Data = SpO2Data.empty();

  @override
  void initState() {
    super.initState();

    watchPayloadService.startListening(
      onHeartRateReceived: (HeartRateData data) {
        if (!mounted) {
          return;
        }

        setState(() {
          heartRateData = heartRateData.mergeWithIncoming(data);
        });
      },
    onSpO2Received: (SpO2Data data) {
      if (!mounted) {
          return;
      }
      setState(() {
        spo2Data = data;
      });
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
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: const Text('Alera'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
Row(
                children: [
                  const Icon(Icons.favorite,
                              color: Colors.red,
                                ),
                  Text('Heart Rate: ''${heartRateData.displayedHeartRate} BPM',),
                ],
              ),
              Text(heartRateData.displayedStatus),
              Text(heartRateData.measuredAt ?? 'No measurement received',),

Row(
                children: [
                  const Icon(Icons.bloodtype,
                              color: Colors.red,
                                ),
                  Text('SpO2: ''${spo2Data.displayedPercent}%',),
                  
                ],
              ),
              Text(spo2Data.displayedStatus),
              Text(spo2Data.measuredAt ?? 'No measurement received',),

              
            ],
          ),
        ),
      ),
    );
  }
}