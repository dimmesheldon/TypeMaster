import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/typing/typing_menu_screen.dart';
import '../../features/typing/typing_lesson_screen.dart';
import '../../features/typing/speed_test_screen.dart';
import '../../features/mouse/mouse_menu_screen.dart';
import '../../features/mouse/mouse_challenge_screen.dart';
import '../../features/statistics/statistics_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../providers/usuario_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final usuario = ref.read(usuarioAtualProvider);
      final naAuth = state.matchedLocation == '/' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/cadastro';

      if (usuario == null && !naAuth) return '/login';
      if (usuario != null && naAuth && state.matchedLocation != '/') return null;
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/cadastro', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/digitacao', builder: (_, __) => const TypingMenuScreen()),
      GoRoute(
        path: '/digitacao/licao/:nivel/:subNivel',
        builder: (_, state) => TypingLessonScreen(
          nivel: state.pathParameters['nivel']!,
          subNivel: int.parse(state.pathParameters['subNivel']!),
        ),
      ),
      GoRoute(
        path: '/digitacao/velocidade',
        builder: (_, __) => const SpeedTestScreen(),
      ),
      GoRoute(path: '/mouse', builder: (_, __) => const MouseMenuScreen()),
      GoRoute(
        path: '/mouse/desafio/:tipo/:nivel/:subNivel',
        builder: (_, state) => MouseChallengeScreen(
          tipo: state.pathParameters['tipo']!,
          nivel: state.pathParameters['nivel']!,
          subNivel: int.parse(state.pathParameters['subNivel']!),
        ),
      ),
      GoRoute(
        path: '/estatisticas',
        builder: (_, __) => const StatisticsScreen(),
      ),
      GoRoute(
        path: '/configuracoes',
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(
        child: Text('Página não encontrada: ${state.error}'),
      ),
    ),
  );
});
