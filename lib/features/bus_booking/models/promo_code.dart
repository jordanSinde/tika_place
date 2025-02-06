// lib/features/bus_booking/models/promo_code.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'promo_code.freezed.dart';
part 'promo_code.g.dart';

@freezed
class PromoCode with _$PromoCode {
  const factory PromoCode({
    required String code,
    required double discountPercent,
    required DateTime validUntil,
    required int maxUsage,
    required List<String> usedByUsers,
    String? description,
    double? minPurchaseAmount,
    double? maxDiscountAmount,
  }) = _PromoCode;

  factory PromoCode.fromJson(Map<String, dynamic> json) =>
      _$PromoCodeFromJson(json);
}

// Extension pour les méthodes utilitaires
extension PromoCodeUtils on PromoCode {
  bool isValid() {
    final now = DateTime.now();
    return now.isBefore(validUntil) && usedByUsers.length < maxUsage;
  }

  bool isValidForUser(String userId) {
    return isValid() && !usedByUsers.contains(userId);
  }

  bool isValidForAmount(double amount) {
    if (minPurchaseAmount != null && amount < minPurchaseAmount!) {
      return false;
    }
    return true;
  }

  double calculateDiscount(double amount) {
    if (!isValid()) return 0;

    double discount = amount * (discountPercent / 100);

    if (maxDiscountAmount != null) {
      discount = discount.clamp(0, maxDiscountAmount!);
    }

    return discount;
  }
}
