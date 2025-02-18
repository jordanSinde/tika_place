//lib/features/bus_booking/services/trip_reminder_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/timezone.dart';
import '../providers/ticket_model.dart';
import 'package:timezone/data/latest.dart';

class TripReminderService {
  static final TripReminderService _instance = TripReminderService._internal();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  factory TripReminderService() {
    return _instance;
  }

  // Add timezone initialization in the constructor
  TripReminderService._internal() {
    // Initialize timezone
    initializeTimeZones();
    setLocalLocation(
        getLocation('Africa/Douala')); // Or another appropriate timezone
  }

  // Initialiser les rappels pour un ticket
  Future<void> scheduleReminders(ExtendedTicket ticket) async {
    try {
      // Calculate the reminder times
      final departureTime = ticket.bus.departureTime;

      // Schedule the reminders
      await _scheduleDayBeforeReminder(ticket);
      await _scheduleSameDayReminder(ticket);
      await _scheduleLastCallReminder(ticket);

      print(
          "✅ REMINDERS: Successfully scheduled reminders for ticket ${ticket.id}");
    } catch (e, stackTrace) {
      print("⚠️ REMINDERS: Error scheduling reminders: $e");
      print("⚠️ REMINDERS: $stackTrace");
      // Continue without throwing - don't block the UI for notification errors
    }
  }

  // Annuler tous les rappels pour un ticket
  Future<void> cancelReminders(String ticketId) async {
    await _notifications.cancel(int.parse(ticketId.hashCode.toString()));
  }

  // Rappel 24h avant
  Future<void> _scheduleDayBeforeReminder(ExtendedTicket ticket) async {
    final scheduledDate =
        ticket.bus.departureTime.subtract(const Duration(days: 1));

    if (scheduledDate.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        _generateNotificationId(ticket.id, 'day_before'),
        'Rappel de voyage - Demain',
        'N\'oubliez pas votre voyage ${ticket.bus.departureCity} → ${ticket.bus.arrivalCity} demain à ${_formatTime(ticket.bus.departureTime)}',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'trip_reminder',
            'Rappels de voyage',
            channelDescription: 'Notifications pour les rappels de voyage',
            importance: Importance.high,
            priority: Priority.high,
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: ticket.id,
      );
    }
  }

  // Rappel le jour même (matin du voyage)
  Future<void> _scheduleSameDayReminder(ExtendedTicket ticket) async {
    final scheduledDate = DateTime(
      ticket.bus.departureTime.year,
      ticket.bus.departureTime.month,
      ticket.bus.departureTime.day,
      8, // 8h du matin
      0,
    );

    if (scheduledDate.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        _generateNotificationId(ticket.id, 'same_day'),
        'Votre voyage aujourd\'hui',
        '''N'oubliez pas votre voyage ${ticket.bus.departureCity} → ${ticket.bus.arrivalCity} aujourd'hui à ${_formatTime(ticket.bus.departureTime)}

Important:
- Présentez-vous 30 minutes avant le départ
- N'oubliez pas votre pièce d'identité
- Siège: ${ticket.formattedSeatNumber}''',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'trip_reminder',
            'Rappels de voyage',
            channelDescription: 'Notifications pour les rappels de voyage',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''),
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: ticket.id,
      );
    }
  }

  // Rappel 2h avant le départ
  Future<void> _scheduleLastCallReminder(ExtendedTicket ticket) async {
    final scheduledDate =
        ticket.bus.departureTime.subtract(const Duration(hours: 2));

    if (scheduledDate.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        _generateNotificationId(ticket.id, 'last_call'),
        'Départ dans 2 heures',
        '''Votre bus pour ${ticket.bus.arrivalCity} part dans 2 heures !

🚌 ${ticket.bus.company}
🎫 ${ticket.formattedSeatNumber}
📍 ${ticket.bus.agencyLocation}

N'oubliez pas vos documents et présentez-vous 30 minutes avant le départ.''',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'trip_reminder',
            'Rappels de voyage',
            channelDescription: 'Notifications pour les rappels de voyage',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''),
            largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: ticket.id,
      );
    }
  }

  // Générer un ID unique pour chaque notification
  int _generateNotificationId(String ticketId, String type) {
    final typeHash = type.hashCode;
    final ticketHash = ticketId.hashCode;
    return (ticketHash + typeHash).abs();
  }

  // Formater l'heure pour l'affichage
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Vérifier les permissions de notification
  Future<bool> checkNotificationPermissions() async {
    return false;
  }
}

// Singleton instance
final tripReminderService = TripReminderService();
