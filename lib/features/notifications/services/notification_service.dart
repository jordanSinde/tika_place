// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../bus_booking/providers/booking_provider.dart';

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

  void _onNotificationTapped(NotificationResponse response) {
    // Gérer la navigation selon le type de notification
    final payload = response.payload;
    if (payload != null) {
      // Implémenter la navigation selon le payload
    }
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

  //DDDDDDDDDDDD
  // Notification de changement de statut
  Future<void> notifyReservationStatusChange({
    required String reservationId,
    required BookingStatus oldStatus,
    required BookingStatus newStatus,
    String? reason,
  }) async {
    String title;
    String body;
    String channelId;
    int priority;

    switch (newStatus) {
      case BookingStatus.confirmed:
        title = 'Réservation confirmée';
        body = 'Votre réservation a été confirmée avec succès';
        channelId = 'confirmation';
        priority = 1;
        break;

      case BookingStatus.cancelled:
        title = 'Réservation annulée';
        body = reason ?? 'Votre réservation a été annulée';
        channelId = 'cancellation';
        priority = 2;
        break;

      case BookingStatus.expired:
        title = 'Réservation expirée';
        body = 'Le délai de paiement a expiré';
        channelId = 'expiration';
        priority = 1;
        break;

      case BookingStatus.failed:
        title = 'Échec de la réservation';
        body = reason ?? 'Une erreur est survenue';
        channelId = 'error';
        priority = 2;
        break;

      default:
        return;
    }

    await _showNotification(
      id: reservationId.hashCode,
      title: title,
      body: body,
      channelId: channelId,
      priority: priority,
      payload: {
        'type': 'status_change',
        'reservationId': reservationId,
        'status': newStatus.toString(),
      },
    );
  }

  // Notification de rappel de paiement
  Future<void> notifyPaymentReminder({
    required String reservationId,
    required DateTime expiresAt,
  }) async {
    final timeLeft = expiresAt.difference(DateTime.now());
    if (timeLeft.inMinutes <= 5 && timeLeft.isNegative == false) {
      await _showNotification(
        id: '${reservationId}_reminder'.hashCode,
        title: 'Rappel de paiement',
        body: 'Votre réservation expire dans ${timeLeft.inMinutes} minutes',
        channelId: 'payment_reminder',
        priority: 2,
        payload: {
          'type': 'payment_reminder',
          'reservationId': reservationId,
        },
      );
    }
  }

  // Notification de disponibilité des places
  Future<void> notifyAvailabilityChange({
    required String reservationId,
    required String busId,
    required bool isAvailable,
  }) async {
    if (!isAvailable) {
      await _showNotification(
        id: '${reservationId}_availability'.hashCode,
        title: 'Places non disponibles',
        body: 'Les places réservées ne sont plus disponibles',
        channelId: 'availability',
        priority: 2,
        payload: {
          'type': 'availability',
          'reservationId': reservationId,
          'busId': busId,
        },
      );
    }
  }

  // Notification de tentative de paiement
  Future<void> notifyPaymentAttempt({
    required String reservationId,
    required bool isSuccess,
    String? errorMessage,
  }) async {
    if (!isSuccess) {
      await _showNotification(
        id: '${reservationId}_payment'.hashCode,
        title: 'Échec du paiement',
        body: errorMessage ?? 'Une erreur est survenue lors du paiement',
        channelId: 'payment_error',
        priority: 2,
        payload: {
          'type': 'payment_error',
          'reservationId': reservationId,
        },
      );
    }
  }

  // Méthode générique pour afficher une notification
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required int priority,
    Map<String, dynamic>? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      'Réservations',
      channelDescription: 'Notifications de réservation',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload:
          payload != null ? Map<String, String>.from(payload).toString() : null,
    );
  }

  // Nettoyer les notifications
  Future<void> clearNotifications() async {
    await _notifications.cancelAll();
  }
}

final notificationService = NotificationService();
//final reservationNotificationService = ReservationNotificationService();