import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/sound_service.dart';
import '../../../data/keyboard/keyboard_layout.dart';

/// Teclado virtual claro e elegante, desenhado a partir do layout escolhido
/// nas configurações, com as teclas coloridas por dedo.
class KeyboardWidget extends StatelessWidget {
  final KeyboardLayout layout;
  final String? teclaAtiva;
  final String? teclaErrada;
  final bool mostrarGuia;

  const KeyboardWidget({
    super.key,
    required this.layout,
    this.teclaAtiva,
    this.teclaErrada,
    this.mostrarGuia = true,
  });

  static const _gap = 5.0;
  static const _padding = 14.0;

  @override
  Widget build(BuildContext context) {
    final linhas = layout.linhas;
    // A largura da tecla cabe na linha mais exigente em unidades e em gaps
    final maxUnidades = linhas
        .map((l) => l.fold<double>(0, (s, k) => s + k.unidades))
        .reduce((a, b) => a > b ? a : b);
    final maxTeclas =
        linhas.map((l) => l.length).reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(builder: (context, constraints) {
      final disponivel =
          constraints.maxWidth - _padding * 2 - maxTeclas * _gap;
      final keyW = (disponivel / maxUnidades).clamp(22.0, 52.0);
      final keyH = keyW * 0.94;

      return Container(
        padding: const EdgeInsets.all(_padding),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < linhas.length; i++) ...[
              if (i > 0) const SizedBox(height: _gap),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final cap in linhas[i])
                    _Tecla(
                      cap: cap,
                      layout: layout,
                      largura: keyW * cap.unidades,
                      altura: keyH,
                      ativa: cap.tecla != null && _ativa(cap.tecla!),
                      errada: cap.tecla != null && _errada(cap.tecla!),
                      mostrarGuia: mostrarGuia,
                    ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  bool _ativa(String k) => teclaAtiva?.toLowerCase() == k.toLowerCase();
  bool _errada(String k) => teclaErrada?.toLowerCase() == k.toLowerCase();
}

class _Tecla extends StatelessWidget {
  final KeyCap cap;
  final KeyboardLayout layout;
  final double largura;
  final double altura;
  final bool ativa;
  final bool errada;
  final bool mostrarGuia;

  const _Tecla({
    required this.cap,
    required this.layout,
    required this.largura,
    required this.altura,
    required this.ativa,
    required this.errada,
    required this.mostrarGuia,
  });

  static const _depth = 3.0;
  static const _gap = 5.0;

  bool get _ehHomeRow => cap.tecla == 'f' || cap.tecla == 'j';

  Color? get _corDedo {
    final k = cap.tecla;
    if (k == null) return null;
    final info = layout.teclas[k];
    return info != null ? AppTheme.corDedo(info.dedo) : null;
  }

  Color get _fundo {
    if (errada) return AppColors.error;
    if (ativa) return _corDedo ?? AppColors.primary;
    if (cap.modificador) return const Color(0xFF8FB5AE);
    if (mostrarGuia && _corDedo != null) {
      return Color.alphaBlend(_corDedo!.withValues(alpha: 0.22), Colors.white);
    }
    return Colors.white;
  }

  Color get _borda {
    if (errada) return AppColors.error;
    if (ativa) return (_corDedo ?? AppColors.primary);
    if (cap.modificador) return const Color(0xFF6E9A92);
    if (mostrarGuia && _corDedo != null) return _corDedo!.withValues(alpha: 0.45);
    return AppColors.border;
  }

  Color get _texto {
    if (errada || ativa) return Colors.white;
    if (cap.modificador) return Colors.white;
    return AppColors.textPrimary;
  }

  Color get _profundidade {
    if (errada) return const Color(0xFF9B1C1C);
    if (ativa) return Color.alphaBlend(Colors.black26, _corDedo ?? AppColors.primary);
    if (cap.modificador) return const Color(0xFF5E8880);
    return AppColors.border;
  }

  @override
  Widget build(BuildContext context) {
    final pressionada = ativa || errada;
    final principal = cap.rotulo;
    final secundaria = cap.rotuloShift;

    return Padding(
      padding: const EdgeInsets.only(right: _gap),
      child: SizedBox(
        width: largura,
        height: altura + _depth,
        child: Stack(
          children: [
            // Base 3D
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: altura,
                decoration: BoxDecoration(
                  color: _profundidade,
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
            // Keycap
            AnimatedPositioned(
              duration: Duration(milliseconds: pressionada ? 55 : 110),
              curve: pressionada ? Curves.easeIn : Curves.easeOut,
              top: pressionada ? _depth : 0,
              left: 0, right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                height: altura,
                decoration: BoxDecoration(
                  color: _fundo,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: _borda, width: pressionada ? 1.6 : 1),
                  boxShadow: ativa
                      ? [BoxShadow(
                          color: (_corDedo ?? AppColors.primary).withValues(alpha: 0.4),
                          blurRadius: 10, spreadRadius: 1,
                        )]
                      : null,
                ),
                child: Center(
                  child: secundaria != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(secundaria, style: TextStyle(
                              fontSize: altura * 0.24,
                              color: _texto.withValues(alpha: 0.6),
                              height: 1.1,
                            )),
                            Text(principal, style: TextStyle(
                              fontSize: altura * 0.3,
                              fontWeight: FontWeight.w600,
                              color: _texto, height: 1.1,
                            )),
                          ],
                        )
                      : Text(
                          principal,
                          style: TextStyle(
                            fontSize: principal.length > 3
                                ? altura * 0.22
                                : principal.length > 1
                                    ? altura * 0.26
                                    : altura * 0.38,
                            fontWeight: ativa ? FontWeight.w700 : FontWeight.w600,
                            color: _texto,
                          ),
                        ),
                ),
              ),
            ),
            // Marcador da home row (F e J)
            if (_ehHomeRow && !pressionada)
              Positioned(
                bottom: _depth + 4,
                left: largura / 2 - 5,
                child: Container(
                  width: 10, height: 2,
                  decoration: BoxDecoration(
                    color: _borda,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Botão de ligar/desligar o som do teclado.
class SoundToggleButton extends StatefulWidget {
  const SoundToggleButton({super.key});

  @override
  State<SoundToggleButton> createState() => _SoundToggleButtonState();
}

class _SoundToggleButtonState extends State<SoundToggleButton> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _enabled = SoundService.instance.enabled;
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _enabled ? 'Som do teclado ativado' : 'Som do teclado desativado',
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          await SoundService.instance.setEnabled(!_enabled);
          setState(() => _enabled = SoundService.instance.enabled);
          if (_enabled) SoundService.instance.playClick();
        },
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: _enabled ? AppColors.primary.withValues(alpha: 0.1) : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _enabled ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
            ),
          ),
          child: Icon(
            _enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: _enabled ? AppColors.primary : AppColors.textMuted,
            size: 18,
          ),
        ),
      ),
    );
  }
}
