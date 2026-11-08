import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class MouseMenuScreen extends StatelessWidget {
  const MouseMenuScreen({super.key});

  static const _niveis = [
    _NivelMouse('iniciante', 'Iniciante', Icons.school, AppColors.iniciante, '0-30% erro'),
    _NivelMouse('medio', 'Médio', Icons.trending_up, AppColors.medio, '0-20% erro'),
    _NivelMouse('avancado', 'Avançado', Icons.flash_on, AppColors.avancado, '0-10% erro'),
    _NivelMouse('hardcore', 'Hardcore', Icons.local_fire_department, AppColors.hardcore, '< 5% erro'),
  ];

  static const _desafios = [
    _DesafioInfo('alvo', 'Clique no Alvo', Icons.gps_fixed, AppColors.accent, 'Clique simples em alvos que aparecem'),
    _DesafioInfo('duplo', 'Duplo Clique', Icons.ads_click, AppColors.warning, 'Dê duplo clique nos quadrados'),
    _DesafioInfo('triplo', 'Triplo Clique', Icons.mouse, AppColors.info, 'Três cliques rápidos nos objetos'),
    _DesafioInfo('direito', 'Clique Direito', Icons.menu_open, AppColors.avancado, 'Use o botão direito do mouse'),
    _DesafioInfo('misto', 'Desafio Misto', Icons.shuffle, AppColors.hardcore, 'Todos os tipos misturados'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Treinamento de Mouse'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
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
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.mouse_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Precisão com Mouse', style: AppTextStyles.headline2),
                      Text('Cliques, alvos e velocidade de reação',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 32),
          Text('Tipo de Desafio', style: AppTextStyles.headline2)
              .animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _desafios.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 96,
            ),
            itemBuilder: (context, i) {
              final d = _desafios[i];
              return _DesafioCard(
                info: d,
                onTap: () => _selecionarNivel(context, d),
              ).animate(delay: Duration(milliseconds: 150 + i * 60))
                  .fadeIn().scale(begin: const Offset(0.95, 0.95));
            },
          ),
        ],
      ),
    );
  }

  void _selecionarNivel(BuildContext context, _DesafioInfo desafio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: desafio.cor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(desafio.icone, color: desafio.cor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(desafio.titulo, style: AppTextStyles.headline3),
                        Text(desafio.descricao, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Selecione o Nível:', style: AppTextStyles.label
                  .copyWith(color: AppColors.textMuted, letterSpacing: 0.8)),
              const SizedBox(height: 10),
              ..._niveis.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/mouse/desafio/${desafio.id}/${n.id}/1');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: n.cor, shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(n.nome,
                                style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                          ),
                          Text(n.faixa, style: AppTextStyles.bodySmall),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _NivelMouse {
  final String id;
  final String nome;
  final IconData icone;
  final Color cor;
  final String faixa;
  const _NivelMouse(this.id, this.nome, this.icone, this.cor, this.faixa);
}

class _DesafioInfo {
  final String id;
  final String titulo;
  final IconData icone;
  final Color cor;
  final String descricao;
  const _DesafioInfo(this.id, this.titulo, this.icone, this.cor, this.descricao);
}

class _DesafioCard extends StatelessWidget {
  final _DesafioInfo info;
  final VoidCallback onTap;

  const _DesafioCard({required this.info, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: info.cor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(info.icone, color: info.cor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(info.titulo, style: AppTextStyles.headline3,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(info.descricao, style: AppTextStyles.bodySmall,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
