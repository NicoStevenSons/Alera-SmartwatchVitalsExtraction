import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'Services/watch_payload_service.dart';
import 'Services/health_event_api_service.dart';
import 'Services/upload_queue_service.dart';
import 'Services/fifo_upload_service.dart';
import 'Services/watch_listener_controller.dart';
import 'Services/background_sync_service.dart';

import 'config/app_config.dart';

//import 'dart:convert';

import 'models/heart_rate_data.dart';
import 'models/spo2_data.dart';
import 'models/steps_data.dart';
import 'models/device_status_data.dart';
import 'models/sleep_data.dart';

import 'widgets/device_status_dialog.dart';
import 'widgets/clear_pending_queue_button.dart';
import 'widgets/sleep_display.dart';
import 'widgets/heart_rate_display.dart';
import 'widgets/spo2_display.dart';
import 'widgets/steps_display.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize( callbackDispatcher,);

  await Workmanager().registerPeriodicTask(
  'alera-periodic-health-upload',
  aleraBackgroundSyncTask,
  frequency: const Duration(
    minutes: 15,
    ),
  constraints: Constraints(
    networkType: NetworkType.connected,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final WatchPayloadService watchPayloadService = 
        WatchPayloadService();

  final HealthEventApiService healthEventApiService =
    HealthEventApiService(
    baseUrl: AppConfig.backendBaseUrl,
    patientId: AppConfig.testPatientId,
  );

final UploadQueueService uploadQueueService = UploadQueueService();
late final FifoUploadService fifoUploadService;
late final WatchListenerController watchListenerController;

  HeartRateData heartRateData = const HeartRateData(bpm: null, status: null, measuredAt: null,);
  SpO2Data spo2Data = SpO2Data.empty();
  StepsData stepsData = StepsData.empty();
  DeviceStatusData deviceStatusData = DeviceStatusData.empty();
  SleepData sleepData = SleepData.empty();

  
  @override
  void initState() {
  super.initState();
  WidgetsBinding.instance.addObserver(this);

  fifoUploadService = FifoUploadService(
    uploadQueueService: uploadQueueService,
    healthEventApiService:
        healthEventApiService,
  );

  watchListenerController =
      WatchListenerController(
    watchPayloadService:
        watchPayloadService,
    uploadQueueService:
        uploadQueueService,
    healthEventApiService:
        healthEventApiService,
    fifoUploadService:
        fifoUploadService,

    onHeartRateUpdated:
        (HeartRateData data) {
      if (!mounted) return;

      setState(() {
        heartRateData = data;

        deviceStatusData =
            deviceStatusData.copyWith(
          connectedToPhone: true,
        );
      });
    },

    onSpO2Updated:
        (SpO2Data data) {
      if (!mounted) return;

      setState(() {
        spo2Data = data;

        deviceStatusData =
            deviceStatusData.copyWith(
          connectedToPhone: true,
        );
      });
    },

    onStepsUpdated:
        (StepsData data) {
      if (!mounted) return;

      setState(() {
        stepsData = data;
      });
    },

    onDeviceStatusUpdated:
        (DeviceStatusData data) {
      if (!mounted) {
        return;
      } 
    debugPrint(
    'MAIN RECEIVED DEVICE STATUS: '
    'battery=${data.batteryPercent}, '
    'device=${data.deviceName}, '
    'model=${data.deviceModel}, '
    'connected=${data.connectedToPhone}, '
    'phone=${data.connectedPhoneName}',
  );
      setState(() {
  deviceStatusData = deviceStatusData.copyWith(
    batteryPercent: data.batteryPercent,
    deviceName: data.deviceName,
    deviceModel: data.deviceModel,
    connectedToPhone: data.connectedToPhone,
    connectedPhoneName: data.connectedPhoneName,
    measuredAt: data.measuredAt,
    );
      });
       },

    onSleepUpdated:
        (SleepData data) {
      if (!mounted) return;

      setState(() {
        sleepData = data;
      });
    },
  );

  watchListenerController.start();

  _processPendingQueue();
}

  Future<void> _processPendingQueue() async {
  if (!AppConfig.enableBackend) {
    return;
  }

  debugPrint(
    'Checking pending upload queue...',
  );

  await fifoUploadService.processQueue();
}

  @override
  void didChangeAppLifecycleState(
  AppLifecycleState state,
) {
  if (state == AppLifecycleState.resumed) {
    debugPrint(
      'App resumed. Processing pending queue.',
    );

    _processPendingQueue();
  }
}
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
                IconButton(icon: Icon(deviceStatusData.connectedToPhone ==true ? Icons.watch : Icons.watch_off,), 
                onPressed:(){
                  showDeviceStatusDialog(
                  context: context,
                  deviceStatusData: deviceStatusData,
                  );
                }
                )
              ],//Actions
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                 HeartRateDisplay(
        heartRateData: heartRateData,
      ),

      const SizedBox(height: 16),

      SpO2Display(
        spo2Data: spo2Data,
      ),

      const SizedBox(height: 16),

      StepsDisplay(
        stepsData: stepsData,
      ),

      const SizedBox(height: 16),

      SleepDisplay(
        sleepData: sleepData,
      ),

      const SizedBox(height: 16),

      ClearPendingQueueButton(
        uploadQueueService:
            uploadQueueService,
      ),
              ],),
            ),
          );
        }
      ),
    );
  }
}