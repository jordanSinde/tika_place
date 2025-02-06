// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PromoCodeImpl _$$PromoCodeImplFromJson(Map<String, dynamic> json) =>
    _$PromoCodeImpl(
      code: json['code'] as String,
      discountPercent: (json['discountPercent'] as num).toDouble(),
      validUntil: DateTime.parse(json['validUntil'] as String),
      maxUsage: (json['maxUsage'] as num).toInt(),
      usedByUsers: (json['usedByUsers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      description: json['description'] as String?,
      minPurchaseAmount: (json['minPurchaseAmount'] as num?)?.toDouble(),
      maxDiscountAmount: (json['maxDiscountAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PromoCodeImplToJson(_$PromoCodeImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'discountPercent': instance.discountPercent,
      'validUntil': instance.validUntil.toIso8601String(),
      'maxUsage': instance.maxUsage,
      'usedByUsers': instance.usedByUsers,
      'description': instance.description,
      'minPurchaseAmount': instance.minPurchaseAmount,
      'maxDiscountAmount': instance.maxDiscountAmount,
    };
