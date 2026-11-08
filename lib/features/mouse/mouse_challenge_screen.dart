import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/usuario_provider.dart';

class MouseChallengeScreen extends ConsumerStatefulWidget {
  final String tipo;
  final String nivel;
  final int subNivel;

  const MouseChallengeScreen({
    super.key,
    required this.tipo,
    required this.nivel,
    required this.subNivel,
  });

  @override
  ConsumerState<MouseChallengeScreen> createState() => _MouseChallengeScreenState();
}

class _MouseChallengeScreenState extends ConsumerState<MouseChallengeScreen> {
  final Random _rng = Random();

  static const _duracao = 60;

  int _acertos = 0;
  int _erros = 0;
  int _segundosRestantes = _duracao;
  bool _iniciado = false;
  bool _concluido = false;
  Timer? _timer;
  Timer? _timerAlvo;

  // Alvos ativos
  final List<_Alvo> _alvos = [];

  final List<int> _temposReacao = [];
  DateTime? _ultimoAlvoApareceu;

  @override
  void dispose() {
    _timer?.cancel();
    _timerAlvo?.cancel();
    super.dispose();
  }

  static const _tiposMisto = ['alvo', 'duplo', 'triplo', 'direito'];

  int _cliquesPorTipo([String? tipo]) {
    switch (tipo ?? widget.tipo) {
      case 'duplo': return 2;
      case 'triplo': return 3;
      default: return 1;
    }
  }

  String _sortearTipoAlvo() => widget.tipo == 'misto'
      ? _tiposMisto[_rng.nextInt(_tiposMisto.length)]
      : widget.tipo;

  int get _velocidadeMs {
    switch (widget.nivel) {
      case 'iniciante': return 3000;
      case 'medio': return 2000;
      case 'avancado': return 1500;
      case 'hardcore': return 800;
      default: return 2000;
    }
  }

  void _iniciar() {
    setState(() => _iniciado = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _segundosRestantes--;
        if (_segundosRestantes <= 0) _finalizar();
      });
    });
    _gerarAlvos();
  }

  void _gerarAlvos() {
    if (!mounted || _concluido) return;
    _timerAlvo?.cancel();
    final tipo = _sortearTipoAlvo();
    setState(() {
      _alvos.add(_Alvo(
        id: _rng.nextInt(99999),
        tipo: tipo,
        x: _rng.nextDouble() * 0.75 + 0.1,
        y: _rng.nextDouble() * 0.65 + 0.1,
        cliquesNecessarios: _cliquesPorTipo(tipo),
        cliquesFeitos: 0,
      ));
      _ultimoAlvoApareceu = DateTime.now();
    });

    _timerAlvo = Timer(Duration(milliseconds: _velocidadeMs), () {
      if (!mounted || _concluido) return;
      // Remove alvos expirados não clicados
      setState(() {
        final antes = _alvos.length;
        _alvos.removeWhere((a) => a.cliquesFeitos < a.cliquesNecessarios);
        final removidos = antes - _alvos.length;
        _erros += removidos;
      });
      _gerarAlvos();
    });
  }

  void _clicarAlvo(_Alvo alvo, int cliques) {
    if (_concluido || !_iniciado) return;

    final idx = _alvos.indexWhere((a) => a.id == alvo.id);
    if (idx < 0) return;

    final botaoCerto = alvo.tipo == 'direito' ? cliques == -1 : cliques != -1;
    var proximo = false;

    setState(() {
      if (!botaoCerto) {
        _erros++;
        _alvos.removeAt(idx);
        proximo = true;
        return;
      }

      final atualizado = alvo.copyWith(cliquesFeitos: alvo.cliquesFeitos + 1);
      if (atualizado.cliquesFeitos >= atualizado.cliquesNecessarios) {
        _acertos++;
        _alvos.removeAt(idx);
        proximo = true;
        if (_ultimoAlvoApareceu != null) {
          _temposReacao.add(
              DateTime.now().difference(_ultimoAlvoApareceu!).inMilliseconds);
        }
      } else {
        _alvos[idx] = atualizado;
      }
    });

    if (proximo) _gerarAlvos();
  }

  void _toqueFundo() {
    if (_concluido) return;
    if (!_iniciado) {
      _iniciar();
      return;
    }
    setState(() => _erros++);
  }

  void _finalizar() {
    _timer?.cancel();
    _timerAlvo?.cancel();
    setState(() {
      _concluido = true;
      _alvos.clear();
    });
    _salvar();
  }

  Future<void> _salvar() async {
    final usuario = ref.read(usuarioAtualProvider);
    if (usuario?.id == null) return;
    final db = ref.read(databaseProvider);
    final total = _acertos + _erros;
    final precisao = total > 0 ? (_acertos / total * 100) : 0.0;
    final tempoMedio = _temposReacao.isNotEmpty
        ? (_temposReacao.fold<int>(0, (s, t) => s + t) / _temposReacao.length).round()
        : 0;

    await db.salvarSessaoMouse(SessaoMouse(
      userId: usuario!.id!,
      nivel: widget.nivel,
      subNivel: widget.subNivel,
      tipoDesafio: widget.tipo,
      acertos: _acertos,
      erros: _erros,
      precisao: precisao,
      tempoReacaoMedioMs: tempoMedio,
      duracaoSegundos: _duracao - _segundosRestantes,
    ));
    ref.invalidate(resumoMouseProvider);
  }

  double get _precisao {
    final total = _acertos + _erros;
    if (total == 0) return 100;
    return (_acertos / total * 100).clamp(0, 100);
  }

  int get _tempoReacaoMedio {
    if (_temposReacao.isEmpty) return 0;
    return (_temposReacao.fold<int>(0, (s, t) => s + t) / _temposReacao.length).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/mouse'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(_tituloPorTipo()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _Contador(valor: '$_segundosRestantes', label: 's', cor: _corCronometro()),
                const SizedBox(width: 16),
                _Contador(valor: '$_acertos', label: '✓', cor: AppColors.success),
                const SizedBox(width: 8),
                _Contador(valor: '$_erros', label: '✗', cor: AppColors.error),
              ],
            ),
          ),
        ],
      ),
      body: _concluido
          ? _TelaResultado(
              acertos: _acertos,
              erros: _erros,
              precisao: _precisao,
              tempoReacaoMs: _tempoReacaoMedio,
              onReiniciar: _reiniciar,
              onVoltar: () => context.go('/mouse'),
            )
          // LayoutBuilder no nível do body para passar as constraints corretas ao Positioned
          : LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Fundo clicável (erros ao clicar fora)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _toqueFundo,
                        onSecondaryTap: _toqueFundo,
                        child: const SizedBox.expand(),
                      ),
                    ),

                    // Instrução inicial
                    if (!_iniciado)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Icon(_iconePorTipo(), color: AppColors.primary, size: 36),
                            ),
                            const SizedBox(height: 20),
                            Text(_instrucaoPorTipo(), style: AppTextStyles.headline2,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _iniciar,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Começar'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('ou clique em qualquer lugar da tela',
                                style: AppTextStyles.bodySmall),
                          ],
                        ).animate().fadeIn(duration: 400.ms),
                      ),

                    // Alvos posicionados diretamente no Stack com as constraints corretas
                    ..._alvos.map((alvo) {
                      const size = 68.0;
                      return Positioned(
                        left: (alvo.x * constraints.maxWidth - size / 2)
                            .clamp(0.0, constraints.maxWidth - size),
                        top: (alvo.y * constraints.maxHeight - size / 2)
                            .clamp(0.0, constraints.maxHeight - size),
                        child: _AlvoWidget(
                          alvo: alvo,
                          size: size,
                          destacarTipo: widget.tipo == 'misto',
                          onClique: (cliques) => _clicarAlvo(alvo, cliques),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
    );
  }

  Color _corCronometro() {
    if (_segundosRestantes > 30) return AppColors.accent;
    if (_segundosRestantes > 10) return AppColors.warning;
    return AppColors.error;
  }

  String _tituloPorTipo() {
    switch (widget.tipo) {
      case 'alvo': return 'Clique no Alvo';
      case 'duplo': return 'Duplo Clique';
      case 'triplo': return 'Triplo Clique';
      case 'direito': return 'Clique Direito';
      case 'misto': return 'Desafio Misto';
      default: return 'Desafio Mouse';
    }
  }

  IconData _iconePorTipo() {
    switch (widget.tipo) {
      case 'misto': return Icons.shuffle;
      case 'duplo': return Icons.ads_click;
      case 'triplo': return Icons.mouse;
      case 'direito': return Icons.menu_open;
      default: return Icons.gps_fixed;
    }
  }

  String _instrucaoPorTipo() {
    switch (widget.tipo) {
      case 'alvo': return 'Clique nos alvos\nquando aparecerem!';
      case 'duplo': return 'Dê DUPLO CLIQUE\nno alvo!';
      case 'triplo': return 'Dê TRÊS CLIQUES\nrápidos no alvo!';
      case 'direito': return 'Use o botão DIREITO\ndo mouse!';
      case 'misto': return 'Círculo: 1 clique · Quadrado: 2 ou 3 cliques\nMarcado com DIR: botão direito';
      default: return 'Clique nos alvos!';
    }
  }

  void _reiniciar() {
    _timer?.cancel();
    _timerAlvo?.cancel();
    setState(() {
      _acertos = 0;
      _erros = 0;
      _segundosRestantes = _duracao;
      _iniciado = false;
      _concluido = false;
      _alvos.clear();
      _temposReacao.clear();
    });
  }
}

class _Alvo {
  final int id;
  final String tipo;
  final double x;
  final double y;
  final int cliquesNecessarios;
  final int cliquesFeitos;

  const _Alvo({
    required this.id,
    required this.tipo,
    required this.x,
    required this.y,
    required this.cliquesNecessarios,
    required this.cliquesFeitos,
  });

  _Alvo copyWith({int? cliquesFeitos}) => _Alvo(
    id: id, tipo: tipo, x: x, y: y,
    cliquesNecessarios: cliquesNecessarios,
    cliquesFeitos: cliquesFeitos ?? this.cliquesFeitos,
  );
}

class _AlvoWidget extends StatelessWidget {
  final _Alvo alvo;
  final double size;
  final bool destacarTipo;
  final void Function(int cliques) onClique;

  const _AlvoWidget({
    required this.alvo,
    required this.size,
    required this.destacarTipo,
    required this.onClique,
  });

  Color get _cor {
    switch (alvo.tipo) {
      case 'duplo': return AppColors.warning;
      case 'triplo': return AppColors.info;
      case 'direito': return AppColors.avancado;
      default: return AppColors.accent;
    }
  }

  IconData get _icone {
    switch (alvo.tipo) {
      case 'duplo': return Icons.ads_click;
      case 'triplo': return Icons.mouse;
      case 'direito': return Icons.menu_open;
      default: return Icons.gps_fixed;
    }
  }

  // Círculo no clique simples, quadrado arredondado nos demais
  BoxShape get _forma => alvo.tipo == 'alvo' ? BoxShape.circle : BoxShape.rectangle;

  String? get _etiqueta {
    if (alvo.cliquesNecessarios > 1) {
      return '${alvo.cliquesFeitos}/${alvo.cliquesNecessarios}';
    }
    if (destacarTipo && alvo.tipo == 'direito') return 'DIR';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: alvo.tipo != 'direito' ? () => onClique(1) : null,
      onSecondaryTap: alvo.tipo == 'direito' ? () => onClique(-1) : null,
      child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _cor.withValues(alpha: 0.15),
        shape: _forma,
        borderRadius: _forma == BoxShape.rectangle ? BorderRadius.circular(14) : null,
        border: Border.all(color: _cor, width: 2),
        boxShadow: [
          BoxShadow(color: _cor.withValues(alpha: 0.25), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_icone, color: _cor, size: size * 0.32),
          if (_etiqueta != null) ...[
            const SizedBox(height: 2),
            Text(
              _etiqueta!,
              style: TextStyle(color: _cor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
      ),
    ).animate().scale(begin: const Offset(0.3, 0.3), duration: 250.ms, curve: Curves.elasticOut);
  }
}

class _Contador extends StatelessWidget {
  final String valor;
  final String label;
  final Color cor;

  const _Contador({required this.valor, required this.label, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Text('$valor $label',
        style: AppTextStyles.bodySmall.copyWith(color: cor, fontWeight: FontWeight.bold));
  }
}

class _TelaResultado extends StatelessWidget {
  final int acertos;
  final int erros;
  final double precisao;
  final int tempoReacaoMs;
  final VoidCallback onReiniciar;
  final VoidCallback onVoltar;

  const _TelaResultado({
    required this.acertos,
    required this.erros,
    required this.precisao,
    required this.tempoReacaoMs,
    required this.onReiniciar,
    required this.onVoltar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              precisao >= 85 ? Icons.emoji_events : Icons.refresh,
              color: precisao >= 85 ? AppColors.warning : AppColors.accent,
              size: 64,
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              precisao >= 95 ? 'Perfeito!' : precisao >= 85 ? 'Ótimo Trabalho!' : 'Pratique Mais!',
              style: AppTextStyles.headline1,
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BigStat(label: 'Acertos', valor: '$acertos', cor: AppColors.success),
                const SizedBox(width: 24),
                _BigStat(label: 'Erros', valor: '$erros', cor: AppColors.error),
                const SizedBox(width: 24),
                _BigStat(label: 'Precisão', valor: '${precisao.toStringAsFixed(0)}%', cor: AppColors.accent),
                const SizedBox(width: 24),
                _BigStat(label: 'Reação', valor: '${tempoReacaoMs}ms', cor: AppColors.primary),
              ],
            ).animate(delay: 300.ms).fadeIn(),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onVoltar,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReiniciar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Novo'),
                  ),
                ),
              ],
            ).animate(delay: 400.ms).fadeIn(),
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
        Text(valor,
            style: AppTextStyles.wpm.copyWith(color: cor, fontSize: 28)),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
