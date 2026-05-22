import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'role_providers.g.dart';

enum AppRole { player, staff }

@Riverpod(keepAlive: true)
class SelectedRole extends _$SelectedRole {
  @override
  AppRole? build() => null;

  Future<void> set(AppRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_role', role.name);
    state = role;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString('selected_role');
    if (v != null) {
      state = AppRole.values.byName(v);
    }
  }
}
