import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loading_provider.g.dart';

@riverpod
class GlobalLoading extends _$GlobalLoading {
  @override
  bool build() => false;

  void startLoading() => state = true;
  void stopLoading() => state = false;
}
