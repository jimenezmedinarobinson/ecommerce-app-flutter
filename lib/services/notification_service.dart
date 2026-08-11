import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_push_notification/easy_push_notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await Firebase.initializeApp();
      EasyPush.I.initialize(EasyPushConfig(
        androidChannelId: 'ecommerce_channel',
        androidChannelName: 'Notificaciones de la Tienda',
        requestIOSPermissions: true,
        showForegroundNotifications: true,
        onNotificationTap: (payload) async {
          print('📱 Notificación tocada: $payload');
        },
      ));
      _isInitialized = true;
      print('✅ Notificaciones inicializadas correctamente');
      await _getFCMToken();
    } catch (e) {
      print('❌ Error inicializando notificaciones: $e');
    }
  }

  Future<String?> _getFCMToken() async {
    try {
      final token = await EasyPush.I.getToken();
      if (token != null) {
        print('📱 FCM Token: $token');
        await _sendTokenToBackend(token);
      }
      return token;
    } catch (e) {
      print('❌ Error obteniendo token FCM: $e');
      return null;
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      print('✅ Token enviado al backend (simulado)');
    } catch (e) {
      print('❌ Error enviando token al backend: $e');
    }
  }

  void listenTokenChanges() {
    EasyPush.I.onTokenRefresh.listen((newToken) {
      print('🔄 Token actualizado: $newToken');
      _sendTokenToBackend(newToken);
    });
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await EasyPush.I.showLocal(
        title: title,
        body: body,
        payload: payload ?? 'home',
      );
      print('✅ Notificación local mostrada');
    } catch (e) {
      print('❌ Error mostrando notificación local: $e');
    }
  }

  Future<bool> requestPermission() async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('❌ Error solicitando permiso: $e');
      return false;
    }
  }

  void setupBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Mensaje en primer plano: ${message.notification?.title}');
    });
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 Mensaje en segundo plano: ${message.notification?.title}');
}
