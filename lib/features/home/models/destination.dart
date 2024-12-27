import 'package:freezed_annotation/freezed_annotation.dart';

part 'destination.freezed.dart';
part 'destination.g.dart';

@freezed
class Destination with _$Destination {
  const factory Destination({
    required String id,
    required String city,
    required String country,
    required String imageUrl,
    String? price,
    @Default(false) bool hasHotels,
    String? description,
  }) = _Destination;

  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);
}
