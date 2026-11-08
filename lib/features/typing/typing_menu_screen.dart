import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/usuario_provider.dart';
import '../../data/lessons/licoes.dart';

class TypingMenuScreen extends ConsumerWidget {
  const TypingMenuScreen({super.key});

  static const _niveis = [
    _NivelInfo('iniciante', 'Iniciante', Icons.school, AppColors.iniciante, '0-30 WPM'),
    _NivelInfo('medio', 'Médio', Icons.trending_up, AppColors.medio, '30-50 WPM'),
    _NivelInfo('avancado', 'Avançado', Icons.flash_on, AppColors.avancado, '50-70 WPM'),
    _NivelInfo('hardcore', 'Hardcore', Icons.local_fire_department, AppColors.hardcore, '70+ WPM'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final niveisDesbloq = ref.watch(niveisDesbloqueadosProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Digitação'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton.icon(
              onPressed: () => context.go('/digitacao/velocidade'),
              icon: const Icon(Icons.speed, size: 18),
              label: const Text('Teste de Velocidade'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.keyboard_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Treinamento de Digitação', style: AppTextStyles.headline2),
                      Text('Touch typing com guia de dedos', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 32),
          Text('Selecione o Nível', style: AppTextStyles.headline2)
              .animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 4),
          Text('Cada nível tem 4 lições progressivas',
              style: AppTextStyles.body)
              .animate(delay: 120.ms).fadeIn(),
          const SizedBox(height: 20),

          ...List.generate(_niveis.length, (i) {
            final n = _niveis[i];
            return niveisDesbloq.when(
              data: (desbloq) {
                final maxSub = desbloq[n.id] ?? 0;
                return _NivelExpansao(
                  info: n,
                  subNivelConcluido: maxSub,
                  onLicaoTap: (sub) => context.go('/digitacao/licao/${n.id}/$sub'),
                ).animate(delay: Duration(milliseconds: 150 + i * 80))
                    .fadeIn().slideY(begin: 0.1, end: 0);
              },
              loading: () => const SizedBox(height: 80,
                  child: Center(child: CircularProgressIndicator())),
              error: (_, __) => _NivelExpansao(
                info: n,
                subNivelConcluido: 0,
                onLicaoTap: (sub) => context.go('/digitacao/licao/${n.id}/$sub'),
              ).animate(delay: Duration(milliseconds: 150 + i * 80)).fadeIn(),
            );
          }),
        ],
      ),
    );
  }
}

class _NivelInfo {
  final String id;
  final String nome;
  final IconData icone;
  final Color cor;
  final String faixaWpm;
  const _NivelInfo(this.id, this.nome, this.icone, this.cor, this.faixaWpm);
}

class _NivelExpansao extends StatefulWidget {
  final _NivelInfo info;
  final int subNivelConcluido;
  final void Function(int sub) onLicaoTap;

  const _NivelExpansao({
    required this.info,
    required this.subNivelConcluido,
    required this.onLicaoTap,
  });

  @override
  State<_NivelExpansao> createState() => _NivelExpansaoState();
}

class _NivelExpansaoState extends State<_NivelExpansao> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    final licoes = BancoLicoes.porNivel(widget.info.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expandido = !_expandido),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: widget.info.cor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.info.icone, color: widget.info.cor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(widget.info.nome, style: AppTextStyles.headline3),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.info.cor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(widget.info.faixaWpm,
                                    style: AppTextStyles.label.copyWith(color: widget.info.cor)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _BarraProgresso(
                            concluido: widget.subNivelConcluido,
                            total: 4,
                            cor: widget.info.cor,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expandido ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            if (_expandido) ...[
              const Divider(color: AppColors.border, height: 1),
              ...licoes.map((l) {
                return _LicaoItem(
                  licao: l,
                  cor: widget.info.cor,
                  concluida: l.subNivel <= widget.subNivelConcluido,
                  onTap: () => widget.onLicaoTap(l.subNivel),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarraProgresso extends StatelessWidget {
  final int concluido;
  final int total;
  final Color cor;

  const _BarraProgresso({required this.concluido, required this.total, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: total > 0 ? concluido / total : 0,
              backgroundColor: AppColors.bgSurface,
              valueColor: AlwaysStoppedAnimation<Color>(cor),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$concluido/$total', style: AppTextStyles.bodySmall.copyWith(color: cor)),
      ],
    );
  }
}

class _LicaoItem extends StatelessWidget {
  final Licao licao;
  final Color cor;
  final bool concluida;
  final VoidCallback onTap;

  const _LicaoItem({
    required this.licao,
    required this.cor,
    required this.concluida,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: concluida ? cor.withValues(alpha: 0.2) : AppColors.bgSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: concluida ? cor : AppColors.border,
                ),
              ),
              child: Icon(
                concluida ? Icons.check : Icons.play_arrow,
                size: 16,
                color: concluida ? cor : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${licao.subNivel}. ${licao.titulo}',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(licao.descricao, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${licao.wpmMeta} WPM',
                    style: AppTextStyles.bodySmall.copyWith(color: cor)),
                Text('${licao.precisaoMinima}% precisão',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
