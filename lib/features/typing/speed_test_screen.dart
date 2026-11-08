import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/usuario_provider.dart';
import '../../core/providers/settings_provider.dart';
import 'widgets/keyboard_widget.dart';

final _textosTeste = [
  'o sol brilha sobre a cidade enquanto as pessoas caminham pelas ruas movimentadas',
  'a tecnologia mudou a forma como nos comunicamos trabalhamos e aprendemos no dia a dia',
  'estudar programação abre portas para oportunidades incríveis no mercado de trabalho atual',
  'cada tecla pressionada com precisão te aproxima de ser um digitador mais rápido e eficiente',
  'a prática constante e dedicada é o único caminho para alcançar a excelência em qualquer habilidade',
  'computadores e internet transformaram o mundo conectando pessoas de todos os continentes em segundos',
  'aprender a digitar sem olhar para o teclado é uma habilidade essencial para trabalhar com computador',
  'a escola de informática prepara alunos para os desafios do mundo digital com conhecimento e prática',
  'velocidade e precisão são as duas qualidades mais importantes para um digitador profissional de sucesso',
  'o futuro pertence às pessoas que aprendem habilidades digitais e sabem aplicá-las com criatividade',
];

class SpeedTestScreen extends ConsumerStatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  ConsumerState<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends ConsumerState<SpeedTestScreen> {
  static const _duracao = 60;

  late final String _texto;
  late final FocusNode _focusNode;
  final TextEditingController _campo = TextEditingController();

  String _digitado = '';
  bool _iniciado = false;
  bool _concluido = false;
  int _segundosRestantes = _duracao;
  int _erros = 0;
  Timer? _timer;
  String _ultimaErrada = '';

  @override
  void initState() {
    super.initState();
    final r = Random();
    _texto = _textosTeste[r.nextInt(_textosTeste.length)] * 3;
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    _campo.dispose();
    super.dispose();
  }

  void _iniciar() {
    _iniciado = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _segundosRestantes--;
        if (_segundosRestantes <= 0) _finalizar();
      });
    });
  }

  void _finalizar() {
    _timer?.cancel();
    setState(() => _concluido = true);
    _salvar();
  }

  Future<void> _salvar() async {
    final usuario = ref.read(usuarioAtualProvider);
    if (usuario?.id == null) return;

    final db = ref.read(databaseProvider);
    await db.salvarSessaoDigitacao(SessaoDigitacao(
      userId: usuario!.id!,
      nivel: 'medio',
      subNivel: 1,
      tipoExercicio: 'velocidade',
      wpm: _wpm,
      precisao: _precisao,
      totalCaracteres: _digitado.length + _erros,
      caracteresCorretos: _digitado.length,
      erros: _erros,
      duracaoSegundos: _duracao - _segundosRestantes,
    ));
    ref.invalidate(resumoDigitacaoProvider);
  }

  int get _wpm {
    final segundos = _duracao - _segundosRestantes;
    if (segundos == 0) return 0;
    final palavras = _digitado.trim().split(' ').where((s) => s.isNotEmpty).length;
    return (palavras / (segundos / 60)).round();
  }

  double get _precisao {
    final total = _digitado.length + _erros;
    if (total == 0) return 100;
    return (_digitado.length / total * 100).clamp(0, 100);
  }

  /// A digitação entra por um campo de texto invisível: só assim o macOS
  /// entrega as letras acentuadas já compostas pela tecla morta.
  void _onTextoMudou(String valor) {
    if (_concluido) return;

    // Tecla morta pendente (´ ~ ^ …): aguarda a letra que vai receber o acento
    if (_campo.value.composing.isValid) return;

    if (valor.length < _digitado.length) {
      if (_digitado.isNotEmpty) {
        setState(() => _digitado = _digitado.substring(0, _digitado.length - 1));
      }
      _sincronizarCampo();
      return;
    }

    final novos = valor.substring(_digitado.length);
    for (final rune in novos.runes) {
      if (_concluido) break;
      _processarCaractere(String.fromCharCode(rune));
    }
    _sincronizarCampo();
  }

  void _sincronizarCampo() {
    if (_campo.text == _digitado) return;
    _campo.value = TextEditingValue(
      text: _digitado,
      selection: TextSelection.collapsed(offset: _digitado.length),
    );
  }

  void _processarCaractere(String char) {
    if (char.isEmpty) return;
    if (!_iniciado) _iniciar();

    final pos = _digitado.length;
    if (pos >= _texto.length) return;

    final esperada = _texto[pos];
    if (char == esperada) {
      setState(() {
        _digitado += char;
        _ultimaErrada = '';
      });
    } else {
      setState(() {
        _erros++;
        _ultimaErrada = char;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/digitacao'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Teste de Velocidade'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: _iniciado && !_concluido ? null : _reiniciar,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Novo Teste'),
            ),
          ),
        ],
      ),
      body: _concluido
          ? _TelaResultado(wpm: _wpm, precisao: _precisao, erros: _erros,
              onReiniciar: _reiniciar, onVoltar: () => context.go('/digitacao'))
          : Stack(
              children: [
              _CampoInvisivel(
                controller: _campo,
                focusNode: _focusNode,
                onChanged: _onTextoMudou,
              ),
              GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Cronômetro
                      _Cronometro(
                        segundos: _segundosRestantes,
                        wpm: _wpm,
                        precisao: _precisao,
                        iniciado: _iniciado,
                      ).animate().fadeIn(),
                      const SizedBox(height: 24),

                      // Texto
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: SingleChildScrollView(
                            child: RichText(
                              text: TextSpan(
                                children: List.generate(_texto.length, (i) {
                                  Color cor;
                                  if (i < _digitado.length) {
                                    cor = AppColors.success;
                                  } else if (i == _digitado.length) {
                                    cor = AppColors.accent;
                                  } else {
                                    cor = AppColors.textMuted;
                                  }
                                  return TextSpan(
                                    text: _texto[i],
                                    style: AppTextStyles.mono.copyWith(color: cor, fontSize: 16),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Mini teclado
                      KeyboardWidget(
                        layout: ref.watch(layoutTecladoProvider),
                        teclaAtiva: _digitado.length < _texto.length ? _texto[_digitado.length] : null,
                        teclaErrada: _ultimaErrada.isNotEmpty ? _ultimaErrada : null,
                        mostrarGuia: false,
                      ),

                      if (!_iniciado)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text('Comece a digitar para iniciar o cronômetro',
                              style: AppTextStyles.body.copyWith(color: AppColors.accent))
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .fadeIn(duration: 800.ms),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            ),
    );
  }

  void _reiniciar() {
    _timer?.cancel();
    setState(() {
      _digitado = '';
      _iniciado = false;
      _concluido = false;
      _segundosRestantes = _duracao;
      _erros = 0;
      _ultimaErrada = '';
    });
    _campo.clear();
    _focusNode.requestFocus();
  }
}

/// Campo de texto fora da vista que recebe a digitação. É ele que entrega as
/// letras acentuadas já compostas pela tecla morta do sistema.
class _CampoInvisivel extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _CampoInvisivel({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      width: 1,
      height: 1,
      child: Opacity(
        opacity: 0,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          enableInteractiveSelection: false,
          showCursor: false,
          maxLines: 1,
          decoration: const InputDecoration.collapsed(hintText: ''),
        ),
      ),
    );
  }
}

class _Cronometro extends StatelessWidget {
  final int segundos;
  final int wpm;
  final double precisao;
  final bool iniciado;

  const _Cronometro({
    required this.segundos,
    required this.wpm,
    required this.precisao,
    required this.iniciado,
  });

  @override
  Widget build(BuildContext context) {
    final porcentagem = segundos / 60;
    final cor = segundos > 30
        ? AppColors.accent
        : segundos > 10
            ? AppColors.warning
            : AppColors.error;

    return Row(
      children: [
        // Cronômetro circular
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: porcentagem,
                  backgroundColor: AppColors.bgSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(cor),
                  strokeWidth: 6,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$segundos',
                    style: AppTextStyles.wpm.copyWith(color: cor, fontSize: 28),
                  ),
                  Text('seg', style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'WPM',
                      valor: iniciado ? '$wpm' : '--',
                      cor: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStat(
                      label: 'Precisão',
                      valor: iniciado ? '${precisao.toStringAsFixed(0)}%' : '--',
                      cor: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;

  const _MiniStat({required this.label, required this.valor, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(valor, style: AppTextStyles.headline2.copyWith(color: cor)),
        ],
      ),
    );
  }
}

class _TelaResultado extends StatelessWidget {
  final int wpm;
  final double precisao;
  final int erros;
  final VoidCallback onReiniciar;
  final VoidCallback onVoltar;

  const _TelaResultado({
    required this.wpm,
    required this.precisao,
    required this.erros,
    required this.onReiniciar,
    required this.onVoltar,
  });

  String get _nivel {
    if (wpm >= 70) return 'TypeMaster! 🏆';
    if (wpm >= 50) return 'Avançado! ⚡';
    if (wpm >= 35) return 'Intermediário 👍';
    if (wpm >= 20) return 'Iniciante 🌱';
    return 'Continue Treinando 💪';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_nivel, style: AppTextStyles.display.copyWith(fontSize: 28))
                .animate().fadeIn(delay: 100.ms).scale(),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BigStat(label: 'WPM', valor: '$wpm', cor: AppColors.accent),
                const SizedBox(width: 24),
                _BigStat(label: 'Precisão', valor: '${precisao.toStringAsFixed(1)}%', cor: AppColors.success),
                const SizedBox(width: 24),
                _BigStat(label: 'Erros', valor: '$erros', cor: AppColors.error),
              ],
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onVoltar,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Lições'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReiniciar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Novo Teste'),
                  ),
                ),
              ],
            ).animate(delay: 300.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;

  const _BigStat({required this.label, required this.valor, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valor, style: AppTextStyles.wpm.copyWith(color: cor)),
        Text(label, style: AppTextStyles.body),
      ],
    );
  }
}
