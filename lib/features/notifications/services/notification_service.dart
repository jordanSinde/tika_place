// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        // Gérer la réponse à la notification ici
      },
    );
  }

  Future<void> showBookingConfirmationNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Réservations',
      channelDescription: 'Notifications de réservation de bus',
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}

final notificationService = NotificationService();
