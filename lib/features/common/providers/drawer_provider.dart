import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'drawer_provider.g.dart';

@riverpod
class DrawerController extends _$DrawerController {
  @override
  bool build() => false; // false = drawer fermé

  void openDrawer() => state = true;
  void closeDrawer() => state = false;
  void toggleDrawer() => state = !state;
}
