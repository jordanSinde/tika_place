import 'package:freezed_annotation/freezed_annotation.dart';

import '../../home/models/destination.dart';

part 'destinations_state.freezed.dart';

@freezed
class DestinationsState with _$DestinationsState {
  const factory DestinationsState({
    @Default([]) List<Destination> destinations,
    @Default(false) bool isLoading,
    String? error,
    @Default([]) List<Destination> featuredDestinations,
    Destination? selectedDestination,
  }) = _DestinationsState;
}
