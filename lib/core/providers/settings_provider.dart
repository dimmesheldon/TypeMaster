import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';
import '../../data/keyboard/keyboard_layout.dart';

final layoutTecladoProvider =
    StateProvider<KeyboardLayout>((ref) => SettingsService.instance.layout);
