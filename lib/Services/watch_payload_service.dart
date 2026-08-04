import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

//dataPayloads
import '../models/heart_rate_data.dart';
import '../models/spo2_data.dart';
import '../models/steps_data.dart';
import '../models/device_status_data.dart';

class WatchPayloadService {
  static const EventChannel _payloadChannel = EventChannel(
    'com.alera.payloadextraction/payloads',
  );

  StreamSubscription<dynamic>? _subscription;

  void startListening({
    required void Function(HeartRateData data) onHeartRateReceived,
    required void Function(SpO2Data data) onSpO2Received,
    required void Function(StepsData data) onStepsReceived,
    required void Function(DeviceStatusData data) onDeviceStatusReceived,
    void Function(Object error)? onError,
  }) {
    _subscription = _payloadChannel
        .receiveBroadcastStream()
        .listen(
          (dynamic event) {
            try {
              final String payloadJson = event.toString();

              final Map<String, dynamic> payload =
                  jsonDecode(payloadJson) as Map<String, dynamic>;

              debugPrint('Flutter received payload: $payload');

              final String? eventType =
                  payload['event_type'] as String?;

              if (eventType == 'heart_rate') {
                final HeartRateData heartRateData =
                    HeartRateData.fromJson(payload);

                onHeartRateReceived(heartRateData);
                return;
              }

              if (eventType == 'spo2') {
                final SpO2Data spo2Data =
                    SpO2Data.fromJson(payload);

                onSpO2Received(spo2Data);
                return;
              }

              if (eventType == 'steps') {
                final StepsData stepsData =
                StepsData.fromJson(payload);

                onStepsReceived(stepsData);
                return;
                    }

              if (eventType == 'device_status') {

                debugPrint(
                'Device status JSON: '
                'battery=${payload['battery_percent']}, '
                'device=${payload['device_name']}, '
                'model=${payload['device_model']}, '
                'connected=${payload['connected_to_phone']}, '
                'phone=${payload['connected_phone_name']}',
                );//removable
                
                final DeviceStatusData deviceStatusData =
                  DeviceStatusData.fromJson(payload);

                onDeviceStatusReceived(deviceStatusData);
                return;
}
                    
              

              debugPrint(
                'Unknown smartwatch payload type: $eventType',
              );
            } on FormatException catch (error) {
              debugPrint('Invalid JSON payload: $error');
              onError?.call(error);
            } catch (error) {
              debugPrint('Could not process payload: $error');
              onError?.call(error);
            }
          },
          onError: (Object error) {
            debugPrint('Payload stream error: $error');
            onError?.call(error);
          },
        );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}