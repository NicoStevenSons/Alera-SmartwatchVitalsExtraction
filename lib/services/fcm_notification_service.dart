import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../features/caregiver/data/auth/caregiver_session_controller.dart';
import '../features/caregiver/data/auth/caregiver_token_store.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FcmNotificationService {
  FcmNotificationService._();
  static final instance = FcmNotificationService._();
  final _local = FlutterLocalNotificationsPlugin();
  final _messaging = FirebaseMessaging.instance;
  String? _token;
  String? get debugToken => kDebugMode ? _token : null;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (r) =>
          _handle(jsonDecode(r.payload ?? '{}')),
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'alera_alerts',
            'Alera alerts',
            description: 'Caregiver health alerts',
            importance: Importance.high,
          ),
        );
    FirebaseMessaging.onMessage.listen(_foreground);
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _handle(m.data));
  }

  Future<void> register(CaregiverSessionController session) async {
    if (session.sessionType != SessionType.caregiver) return;
    try {
      await _messaging.requestPermission();
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      _token = token;
      await _send(token, session.accessToken);
      _messaging.onTokenRefresh.listen((t) async {
        _token = t;
        await _send(t, session.accessToken);
      });
    } catch (_) {}
  }

  Future<void> unregister(CaregiverSessionController session) async {
    final token = _token;
    if (token == null) return;
    try {
      await http.delete(
        Uri.parse('${AppConfig.backendBaseUrl}/api/v1/devices/fcm-token'),
        headers: {
          'authorization': 'Bearer ${session.accessToken}',
          'content-type': 'application/json',
        },
        body: jsonEncode({'token': token}),
      );
    } catch (_) {}
    _token = null;
  }

  Future<void> _send(String token, String? bearer) async {
    if (bearer == null) return;
    try {
      await http.post(
        Uri.parse('${AppConfig.backendBaseUrl}/api/v1/devices/fcm-token'),
        headers: {
          'authorization': 'Bearer $bearer',
          'content-type': 'application/json',
        },
        body: jsonEncode({'token': token, 'platform': 'ANDROID'}),
      );
    } catch (_) {}
  }

  Future<void> _foreground(RemoteMessage m) async {
    final d = m.data;
    await _local.show(
      m.hashCode,
      m.notification?.title ?? 'Alera health alert',
      m.notification?.body ?? 'A new alert needs your attention.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alera_alerts',
          'Alera alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(d),
    );
  }

  void _handle(Map<String, dynamic> data) {
    if (data['type'] == 'ALERT' && data['alert_id'] is String) {
      NotificationTapBus.instance.handle(data['alert_id'] as String);
    }
  }
}

class NotificationTapBus {
  NotificationTapBus._();
  static final instance = NotificationTapBus._();
  void Function(String)? onAlert;
  void handle(String id) => onAlert?.call(id);
}
