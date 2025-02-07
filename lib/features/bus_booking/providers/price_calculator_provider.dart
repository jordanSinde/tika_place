// lib/features/bus_booking/providers/price_calculator_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/promo_code.dart';

class PriceCalculatorState {
  final double subtotal;
  final double mobileTax;
  final double commission;
  final double transportTax;
  final double discount;
  final PromoCode? appliedPromoCode;
  final String? error;

  PriceCalculatorState({
    required this.subtotal,
    this.mobileTax = 0,
    this.commission = 0,
    this.transportTax = 0,
    this.discount = 0,
    this.appliedPromoCode,
    this.error,
  });

  double get total =>
      subtotal + mobileTax + commission + transportTax - discount;

  PriceCalculatorState copyWith({
    double? subtotal,
    double? mobileTax,
    double? commission,
    double? transportTax,
    double? discount,
    PromoCode? appliedPromoCode,
    String? error,
  }) {
    return PriceCalculatorState(
      subtotal: subtotal ?? this.subtotal,
      mobileTax: mobileTax ?? this.mobileTax,
      commission: commission ?? this.commission,
      transportTax: transportTax ?? this.transportTax,
      discount: discount ?? this.discount,
      appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
      error: error,
    );
  }
}

class PriceCalculatorNotifier extends StateNotifier<PriceCalculatorState> {
  PriceCalculatorNotifier() : super(PriceCalculatorState(subtotal: 0));

  // Constantes pour les taxes et commissions
  static const double mobileTaxeRate = 0.025; // 2.5%
  static const double transportTaxeRate = 0.01; // 1%

  void calculatePrice(double basePrice) {
    final mobileTax = basePrice * mobileTaxeRate;
    final commission = _calculateCommission(basePrice);
    final transportTax = basePrice * transportTaxeRate;

    state = state.copyWith(
      subtotal: basePrice,
      mobileTax: mobileTax,
      commission: commission,
      transportTax: transportTax,
    );
  }

  double _calculateCommission(double amount) {
    if (amount <= 10000) {
      return amount * 0.022; // 2.2%
    } else if (amount <= 20000) {
      return amount * 0.018; // 1.8%
    } else {
      return amount * 0.016; // 1.6%
    }
  }

  Future<void> applyPromoCode(String code, String userId) async {
    // Simuler une vérification du code promo
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final promoCode = await _validatePromoCode(code, userId);

      if (promoCode == null) {
        state = state.copyWith(
          error: 'Code promo invalide ou expiré',
          discount: 0,
          appliedPromoCode: null,
        );
        return;
      }

      if (!promoCode.isValidForUser(userId)) {
        state = state.copyWith(
          error: 'Vous avez déjà utilisé ce code promo',
          discount: 0,
          appliedPromoCode: null,
        );
        return;
      }

      if (!promoCode.isValidForAmount(state.subtotal)) {
        state = state.copyWith(
          error: 'Montant minimum non atteint pour ce code promo',
          discount: 0,
          appliedPromoCode: null,
        );
        return;
      }

      final discount = promoCode.calculateDiscount(state.subtotal);
      state = state.copyWith(
        discount: discount,
        appliedPromoCode: promoCode,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Erreur lors de la validation du code promo',
        discount: 0,
        appliedPromoCode: null,
      );
    }
  }

  void removePromoCode() {
    state = state.copyWith(
      discount: 0,
      appliedPromoCode: null,
      error: null,
    );
  }

  // Simule la validation d'un code promo
  Future<PromoCode?> _validatePromoCode(String code, String userId) async {
    // Simulation de codes promo pour test
    final mockPromoCodes = {
      'WELCOME': PromoCode(
        code: 'WELCOME',
        discountPercent: 10,
        validUntil: DateTime.now().add(const Duration(days: 30)),
        maxUsage: 100,
        usedByUsers: [],
        description: 'Code de bienvenue -10%',
        minPurchaseAmount: 5000,
        maxDiscountAmount: 5000,
      ),
      'SUMMER': PromoCode(
        code: 'SUMMER',
        discountPercent: 15,
        validUntil: DateTime.now().add(const Duration(days: 60)),
        maxUsage: 50,
        usedByUsers: [],
        description: 'Promotion été -15%',
        minPurchaseAmount: 10000,
        maxDiscountAmount: 10000,
      ),
    };

    return mockPromoCodes[code.toUpperCase()];
  }
}

final priceCalculatorProvider =
    StateNotifierProvider<PriceCalculatorNotifier, PriceCalculatorState>((ref) {
  return PriceCalculatorNotifier();
});
