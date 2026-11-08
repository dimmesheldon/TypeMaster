import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/usuario_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioAtualProvider);
    final resumoAsync = ref.watch(resumoDigitacaoProvider);

    if (usuario == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          // Sidebar
          _Sidebar(onNavigate: (route) => context.go(route)),
          // Conteúdo principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, ${usuario.nome.split(' ').first}!',
                              style: AppTextStyles.headline1,
                            ),
                            const SizedBox(height: 2),
                            Text('Pronto para treinar hoje?', style: AppTextStyles.body),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ref.read(usuarioAtualProvider.notifier).state = null;
                          context.go('/login');
                        },
                        icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                        label: const Text('Trocar de usuário'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          textStyle: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _mostrarPerfil(context, ref),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: usuario.cor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: usuario.cor.withValues(alpha: 0.4)),
                          ),
                          child: Center(
                            child: Text(
                              usuario.iniciais,
                              style: AppTextStyles.headline3.copyWith(
                                color: usuario.cor, fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 24),

                  // Stats compactos
                  resumoAsync.when(
                    data: (resumo) => Row(
                      children: [
                        _StatChip(
                          label: 'Melhor WPM',
                          value: '${resumo.melhorWpm}',
                          unit: 'wpm',
                          icon: Icons.speed_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          label: 'Precisão Média',
                          value: resumo.mediaPrecisao.toStringAsFixed(0),
                          unit: '%',
                          icon: Icons.gps_fixed_rounded,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          label: 'Sessões',
                          value: '${resumo.totalSessoes}',
                          unit: '',
                          icon: Icons.bar_chart_rounded,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          label: 'Total Erros',
                          value: '${resumo.totalErros}',
                          unit: '',
                          icon: Icons.close_rounded,
                          color: AppColors.warning,
                        ),
                      ],
                    ).animate(delay: 100.ms).fadeIn(),
                    loading: () => const SizedBox(height: 56),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 28),

                  // Módulos
                  Text('Módulos de Treino', style: AppTextStyles.headline3
                      .copyWith(color: AppColors.textSecondary))
                      .animate(delay: 150.ms).fadeIn(),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _ModuleCard(
                          titulo: 'Digitação',
                          subtitulo: 'Aprenda a posição correta dos dedos com guia visual',
                          icone: Icons.keyboard_rounded,
                          cor: AppColors.primary,
                          tag: '16 lições',
                          onTap: () => context.go('/digitacao'),
                        ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.05, end: 0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModuleCard(
                          titulo: 'Mouse',
                          subtitulo: 'Treine precisão, velocidade de reação e tipos de clique',
                          icone: Icons.mouse_rounded,
                          cor: AppColors.accent,
                          tag: '6 desafios',
                          onTap: () => context.go('/mouse'),
                        ).animate(delay: 250.ms).fadeIn().slideX(begin: 0.05, end: 0),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Acesso Rápido
                  Text('Acesso Rápido', style: AppTextStyles.headline3
                      .copyWith(color: AppColors.textSecondary))
                      .animate(delay: 300.ms).fadeIn(),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickTile(
                          titulo: 'Teste de Velocidade',
                          subtitulo: 'Meça seu WPM em 60 segundos',
                          icone: Icons.flash_on_rounded,
                          cor: AppColors.warning,
                          onTap: () => context.go('/digitacao/velocidade'),
                        ).animate(delay: 350.ms).fadeIn(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickTile(
                          titulo: 'Estatísticas',
                          subtitulo: 'Progresso detalhado por dedo e sessão',
                          icone: Icons.analytics_rounded,
                          cor: AppColors.success,
                          onTap: () => context.go('/estatisticas'),
                        ).animate(delay: 400.ms).fadeIn(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickTile(
                          titulo: 'Lição Iniciante',
                          subtitulo: 'Começar pela lição 1',
                          icone: Icons.play_arrow_rounded,
                          cor: AppColors.info,
                          onTap: () => context.go('/digitacao/licao/iniciante/1'),
                        ).animate(delay: 450.ms).fadeIn(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarPerfil(BuildContext context, WidgetRef ref) {
    final usuario = ref.read(usuarioAtualProvider);
    if (usuario == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: usuario.cor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(usuario.iniciais,
                    style: TextStyle(color: usuario.cor, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Text(usuario.nome, style: AppTextStyles.headline3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${usuario.totalSessoes} sessões realizadas', style: AppTextStyles.body),
            Text('${usuario.totalMinutos} minutos de treino', style: AppTextStyles.body),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(usuarioAtualProvider.notifier).state = null;
              context.go('/login');
            },
            child: Text('Trocar usuário',
                style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Fechar',
                style: AppTextStyles.body.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// Sidebar de navegação lateral
class _Sidebar extends StatelessWidget {
  final void Function(String route) onNavigate;

  const _Sidebar({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.keyboard_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 28),
          _SidebarIcon(icon: Icons.home_rounded, label: 'Home', onTap: () => onNavigate('/home')),
          _SidebarIcon(icon: Icons.keyboard_rounded, label: 'Digitação', onTap: () => onNavigate('/digitacao')),
          _SidebarIcon(icon: Icons.mouse_rounded, label: 'Mouse', onTap: () => onNavigate('/mouse')),
          _SidebarIcon(icon: Icons.analytics_rounded, label: 'Stats', onTap: () => onNavigate('/estatisticas')),
          const Spacer(),
          _SidebarIcon(icon: Icons.settings_rounded, label: 'Configurações', onTap: () => onNavigate('/configuracoes')),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SidebarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SidebarIcon({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 44,
          height: 44,
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppColors.textMuted, size: 22),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(value,
                          style: AppTextStyles.headline3.copyWith(color: color, fontSize: 16)),
                      if (unit.isNotEmpty) ...[
                        const SizedBox(width: 2),
                        Text(unit,
                            style: AppTextStyles.bodySmall.copyWith(color: color, fontSize: 10)),
                      ],
                    ],
                  ),
                  Text(label, style: AppTextStyles.bodySmall, maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Color cor;
  final String tag;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.cor,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(titulo, style: AppTextStyles.headline3),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(tag,
                              style: AppTextStyles.bodySmall.copyWith(color: cor, fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitulo, style: AppTextStyles.bodySmall, maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;
  final Color cor;
  final VoidCallback onTap;

  const _QuickTile({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icone, color: cor, size: 20),
              const SizedBox(height: 8),
              Text(titulo, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(subtitulo, style: AppTextStyles.bodySmall,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
