import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/keyboard/keyboard_layout.dart';

/// Guia com o desenho das duas mãos; o dedo que deve ser usado fica em vermelho.
class HandGuideWidget extends StatelessWidget {
  final KeyboardLayout layout;
  final String? proximaTecla;

  const HandGuideWidget({super.key, required this.layout, this.proximaTecla});

  // Proporção das imagens das mãos
  static const _razao = 433 / 637;

  @override
  Widget build(BuildContext context) {
    final info = proximaTecla != null ? layout.infoTecla(proximaTecla!) : null;

    return LayoutBuilder(builder: (context, c) {
      // Cada mão ocupa a altura disponível, respeitando também a largura
      var h = c.maxHeight;
      var w = h * _razao;
      final larguraTotal = w * 2.25;
      if (larguraTotal > c.maxWidth) {
        w = c.maxWidth / 2.25;
        h = w / _razao;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: w, height: h,
            child: _Mao(
              mao: 'esquerda',
              dedoAtivo: info?.mao == 'esquerda' ? info!.dedo : null,
            ),
          ),
          SizedBox(width: w * 0.25),
          SizedBox(
            width: w, height: h,
            child: _Mao(
              mao: 'direita',
              dedoAtivo: info?.mao == 'direita' ? info!.dedo : null,
            ),
          ),
        ],
      );
    });
  }
}

class _Mao extends StatelessWidget {
  final String mao;
  final String? dedoAtivo;

  const _Mao({required this.mao, this.dedoAtivo});

  static const _dedos = ['minimo', 'anelar', 'medio', 'indicador', 'polegar'];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/mao_$mao.png', fit: BoxFit.contain),
        for (final dedo in _dedos)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            opacity: dedo == dedoAtivo ? 1.0 : 0.0,
            child: Image.asset(
              'assets/images/mao_${mao}_$dedo.png',
              fit: BoxFit.contain,
              color: AppColors.error,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
      ],
    );
  }
}
