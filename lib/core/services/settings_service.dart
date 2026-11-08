import 'package:shared_preferences/shared_preferences.dart';
import '../../data/keyboard/keyboard_layout.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._();
  static SettingsService get instance => _instance;

  SettingsService._();

  static const _kLayout = 'keyboard_layout';

  bool _initialized = false;
  KeyboardLayout _layout = LayoutsTeclado.padrao;

  KeyboardLayout get layout => _layout;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final prefs = await SharedPreferences.getInstance();
    _layout = LayoutsTeclado.porId(prefs.getString(_kLayout));
  }

  Future<void> setLayout(KeyboardLayout value) async {
    _layout = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLayout, value.id);
  }
}
