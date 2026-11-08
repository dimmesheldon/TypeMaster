import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/sound_service.dart';
import '../../data/keyboard/keyboard_layout.dart';
import '../typing/widgets/keyboard_widget.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _som = SoundService.instance.enabled;

  @override
  Widget build(BuildContext context) {
    final layout = ref.watch(layoutTecladoProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _Cabecalho(
            icone: Icons.tune_rounded,
            titulo: 'Preferências',
            subtitulo: 'Ajuste o teclado e o som do treinamento',
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 28),
          Text('Layout do Teclado', style: AppTextStyles.headline2)
              .animate(delay: 80.ms).fadeIn(),
          const SizedBox(height: 4),
          Text(
            'Escolha o teclado que o aluno usa nesta máquina. O guia de dedos e '
            'a forma de digitar os acentos mudam conforme a escolha.',
            style: AppTextStyles.body,
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 14),

          ...LayoutsTeclado.todos.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _OpcaoLayout(
                  layout: l,
                  selecionado: l.id == layout.id,
                  onTap: () {
                    ref.read(layoutTecladoProvider.notifier).state = l;
                    SettingsService.instance.setLayout(l);
                  },
                ),
              ).animate(delay: 140.ms).fadeIn()),

          const SizedBox(height: 10),
          Text('Pré-visualização', style: AppTextStyles.label
              .copyWith(color: AppColors.textMuted, letterSpacing: 0.8))
              .animate(delay: 180.ms).fadeIn(),
          const SizedBox(height: 10),
          KeyboardWidget(layout: layout, mostrarGuia: true)
              .animate(delay: 200.ms).fadeIn(),

          const SizedBox(height: 32),
          Text('Som', style: AppTextStyles.headline2)
              .animate(delay: 220.ms).fadeIn(),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: SwitchListTile(
              value: _som,
              activeTrackColor: AppColors.primary,
              onChanged: (v) async {
                await SoundService.instance.setEnabled(v);
                setState(() => _som = v);
                if (v) SoundService.instance.playClick();
              },
              title: Text('Som das teclas', style: AppTextStyles.body
                  .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              subtitle: Text('Clique a cada acerto e aviso nos erros',
                  style: AppTextStyles.bodySmall),
              secondary: Icon(
                _som ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: _som ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ).animate(delay: 240.ms).fadeIn(),
        ],
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String subtitulo;

  const _Cabecalho({
    required this.icone,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppTextStyles.headline2),
                Text(subtitulo, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcaoLayout extends StatelessWidget {
  final KeyboardLayout layout;
  final bool selecionado;
  final VoidCallback onTap;

  const _OpcaoLayout({
    required this.layout,
    required this.selecionado,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selecionado ? AppColors.primary : AppColors.border,
              width: selecionado ? 1.6 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selecionado
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selecionado ? AppColors.primary : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(layout.nome, style: AppTextStyles.headline3.copyWith(
                      color: selecionado ? AppColors.primary : AppColors.textPrimary,
                    )),
                    const SizedBox(height: 3),
                    Text(layout.descricao, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final exemplo in const ['á', 'ã', 'ç'])
                          _ExemploAcento(layout: layout, caractere: exemplo),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mostra como um caractere acentuado é digitado no layout.
class _ExemploAcento extends StatelessWidget {
  final KeyboardLayout layout;
  final String caractere;

  const _ExemploAcento({required this.layout, required this.caractere});

  @override
  Widget build(BuildContext context) {
    final passos = layout.passos(caractere);
    final sequencia = passos.map((p) => p.rotulo).join(' › ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '$caractere  =  $sequencia',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
