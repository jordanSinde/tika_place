// lib/features/bus_booking/screens/booking/bus_booking_process_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../home/models/bus_and_utility_models.dart';
import '../paiement/payment_step.dart';
import '../providers/booking_provider.dart';
import '../providers/price_calculator_provider.dart';
import '../widgets/booking_step_indicator.dart';
import '../widgets/passenger_info_step.dart';
import '../widgets/trip_summary_step.dart';

class BusBookingProcessScreen extends ConsumerStatefulWidget {
  final Bus selectedBus;

  const BusBookingProcessScreen({
    super.key,
    required this.selectedBus,
  });

  @override
  ConsumerState<BusBookingProcessScreen> createState() =>
      _BusBookingProcessScreenState();
}

class _BusBookingProcessScreenState
    extends ConsumerState<BusBookingProcessScreen> {
  int _currentStep = 0;
  final int _totalSteps = 3;

// Dans BusBookingProcessScreen
  @override
  void initState() {
    super.initState();
    Future(() {
      final user = ref.read(authProvider).user;
      if (user != null) {
        // Initialiser le booking avec le bus sélectionné et l'utilisateur
        ref
            .read(bookingProvider.notifier)
            .initializeBooking(widget.selectedBus, user);

        // Calculer le prix initial basé sur le prix du bus
        if (widget.selectedBus.price > 0) {
          ref
              .read(priceCalculatorProvider.notifier)
              .calculatePrice(widget.selectedBus.price);
        }
      }
    });
  }
  /*@override
  void initState() {
    super.initState();
    Future(() {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref
            .read(bookingProvider.notifier)
            .initializeBooking(widget.selectedBus, user);
      }
    });
  }*/

  final List<String> _stepTitles = [
    'Votre Sélection',
    'Vos Informations',
    'Dernière Etape',
  ];

  void _onNextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _onPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget _buildCurrentStep() {
    final user = ref.read(authProvider).user;
    if (user == null) {
      return const Center(child: Text('Veuillez vous connecter'));
    }
    switch (_currentStep) {
      case 0:
        return TripSummaryStep(
          bus: widget.selectedBus,
          onNext: _onNextStep,
        );
      case 1:
        return PassengerInfoStep(
          onNext: _onNextStep,
          onPrevious: _onPreviousStep,
        );
      case 2:
        return PaymentStep(
          onPrevious: _onPreviousStep,
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _onPreviousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          BookingStepIndicator(
            currentStep: _currentStep,
            steps: _stepTitles,
          ),
          Expanded(
            child: _buildCurrentStep(),
          ),
        ],
      ),
    );
  }
}
