// lib/features/bus_booking/services/reservation_service.dart

import 'dart:async';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import '../models/promo_code.dart';

class ReservationService {
  static final ReservationService _instance = ReservationService._internal();

  factory ReservationService() {
    return _instance;
  }

  ReservationService._internal();

  // Create a new reservation from booking state
  Future<TicketReservation> createReservationFromBooking(
      BookingState bookingState) async {
    print('🏗️ RESERVATION SERVICE: Creating reservation from booking');

    if (bookingState.selectedBus == null || bookingState.passengers.isEmpty) {
      throw Exception('Cannot create reservation: missing bus or passengers');
    }

    // Convert passengers to PassengerInfo objects
    final passengerInfos = bookingState.passengers
        .map((passenger) => PassengerInfo(
              firstName: passenger.firstName,
              lastName: passenger.lastName,
              phoneNumber: passenger.phoneNumber,
              cniNumber: passenger.cniNumber,
              isMainPassenger: passenger.isMainPassenger,
            ))
        .toList();

    final totalAmount = bookingState.totalAmount ??
        (bookingState.selectedBus!.price * passengerInfos.length);

    // Create reference if not exists
    final bookingReference = bookingState.bookingReference ??
        'BK${DateTime.now().millisecondsSinceEpoch}';

    // Create expiration time (30 minutes from now)
    final expiresAt = DateTime.now().add(const Duration(minutes: 30));

    // Convert promo code if applied
    PromoCode? promoCode;
    if (bookingState.appliedPromoCode != null) {
      // This is a simplification. In a real app, you'd retrieve the full PromoCode object
      promoCode = PromoCode(
        code: bookingState.appliedPromoCode!,
        discountPercent: 0, // These would be retrieved from a database
        validUntil: DateTime.now().add(const Duration(days: 30)),
        maxUsage: 1,
        usedByUsers: [],
      );
    }

    // Create the reservation
    final reservation = TicketReservation(
      id: bookingReference,
      bus: bookingState.selectedBus!,
      passengers: passengerInfos,
      status: BookingStatus.pending,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      userId: bookingState.userId ?? 'unknown',
      appliedPromoCode: promoCode,
      discountAmount: bookingState.appliedDiscount,
    );

    print('✅ RESERVATION SERVICE: Reservation created successfully');
    print('📋 Reservation ID: ${reservation.id}');
    print('📋 Status: ${reservation.status}');
    print('📋 Expires at: ${reservation.expiresAt}');

    return reservation;
  }

  // Update reservation status
  Future<TicketReservation> updateReservationStatus(
      TicketReservation reservation, BookingStatus newStatus) async {
    print('🔄 RESERVATION SERVICE: Updating reservation status');
    print('📋 Reservation ID: ${reservation.id}');
    print('📋 Old status: ${reservation.status}');
    print('📋 New status: $newStatus');

    final updatedReservation = reservation.copyWith(status: newStatus);

    print('✅ RESERVATION SERVICE: Status updated successfully');
    return updatedReservation;
  }

  // Check if seats are still available for this reservation
  Future<bool> checkSeatsAvailability(TicketReservation reservation) async {
    // In a real app, this would check against a database
    print('🔍 RESERVATION SERVICE: Checking seat availability');
    print('📋 Reservation ID: ${reservation.id}');
    print('📋 Passengers: ${reservation.passengers.length}');
    print('📋 Available seats: ${reservation.bus.availableSeats}');

    final isAvailable =
        reservation.bus.availableSeats >= reservation.passengers.length;

    print(isAvailable
        ? '✅ RESERVATION SERVICE: Seats are available'
        : '❌ RESERVATION SERVICE: Not enough seats available');

    return isAvailable;
  }
}

// Singleton instance
final reservationService = ReservationService();
