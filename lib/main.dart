import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/sound_service.dart';
import 'core/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundService.instance.init();
  await SettingsService.instance.init();
  runApp(const ProviderScope(child: TypeMasterApp()));
}

class TypeMasterApp extends ConsumerWidget {
  const TypeMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TypeMaster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
