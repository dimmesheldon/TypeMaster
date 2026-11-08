import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/providers/database_provider.dart';
import '../../core/providers/usuario_provider.dart';
import '../../data/lessons/licoes.dart';
import '../../data/keyboard/keyboard_layout.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/sound_service.dart';
import 'widgets/keyboard_widget.dart';
import 'widgets/hand_guide_widget.dart';

class TypingLessonScreen extends ConsumerStatefulWidget {
  final String nivel;
  final int subNivel;

  const TypingLessonScreen({
    super.key,
    required this.nivel,
    required this.subNivel,
  });

  @override
  ConsumerState<TypingLessonScreen> createState() => _TypingLessonScreenState();
}

class _TypingLessonScreenState extends ConsumerState<TypingLessonScreen>
    with SingleTickerProviderStateMixin {
  late final Licao _licao;
  late final FocusNode _focusNode;
  final TextEditingController _campo = TextEditingController();

  KeyboardLayout get _layout => ref.read(layoutTecladoProvider);

  int _textoIndex = 0;
  String get _textoAtual => _licao.textos[_textoIndex];

  String _digitado = '';
  int _erros = 0;
  int _errosTotal = 0;
  bool _iniciado = false;
  bool _concluido = false;
  bool _mostrarResultado = false;

  int _segundosDecorridos = 0;
  Timer? _timer;

  String _ultimaTeclaErrada = '';

  // Estatísticas por tecla
  final Map<String, int> _acertosPorTecla = {};
  final Map<String, int> _errosPorTecla = {};
  final Map<String, List<int>> _temposPorTecla = {};
  DateTime? _ultimaPresssao;

  @override
  void initState() {
    super.initState();
    _licao = BancoLicoes.buscar(widget.nivel, widget.subNivel) ??
        Licao(
          nivel: widget.nivel,
          subNivel: widget.subNivel,
          titulo: 'Lição ${widget.subNivel}',
          descricao: '',
          instrucao: '',
          textos: ['Digite este texto de exemplo para praticar.'],
        );
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

  void _iniciarTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _segundosDecorridos++);
    });
  }

  void _pararTimer() {
    _timer?.cancel();
  }

  int get _wpm {
    if (_segundosDecorridos == 0) return 0;
    final minutos = _segundosDecorridos / 60;
    final palavras = _digitado.trim().split(' ').where((s) => s.isNotEmpty).length;
    return (palavras / minutos).round();
  }

  double get _precisao {
    final total = _digitado.length + _errosTotal;
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

  /// Mantém o campo invisível espelhando exatamente o texto já aceito.
  void _sincronizarCampo() {
    if (_campo.text == _digitado) return;
    _campo.value = TextEditingValue(
      text: _digitado,
      selection: TextSelection.collapsed(offset: _digitado.length),
    );
  }

  void _processarCaractere(String char) {
    if (char.isEmpty) return;

    if (!_iniciado) {
      _iniciado = true;
      _iniciarTimer();
    }

    final pos = _digitado.length;
    if (pos >= _textoAtual.length) return;

    final esperada = _textoAtual[pos];
    final agora = DateTime.now();
    final tempo = _ultimaPresssao != null
        ? agora.difference(_ultimaPresssao!).inMilliseconds
        : 0;
    _ultimaPresssao = agora;

    _temposPorTecla[esperada] ??= [];
    _temposPorTecla[esperada]!.add(tempo);

    if (char == esperada) {
      SoundService.instance.playClick();
      _acertosPorTecla[esperada] = (_acertosPorTecla[esperada] ?? 0) + 1;
      setState(() {
        _digitado += char;
        _ultimaTeclaErrada = '';
        _erros = 0;
      });
      if (_digitado.length == _textoAtual.length) {
        _proximoTexto();
      }
    } else {
      SoundService.instance.playError();
      _errosPorTecla[esperada] = (_errosPorTecla[esperada] ?? 0) + 1;
      setState(() {
        _errosTotal++;
        _erros++;
        _ultimaTeclaErrada = char;
      });
    }
  }

  void _proximoTexto() {
    if (_textoIndex < _licao.textos.length - 1) {
      setState(() {
        _textoIndex++;
        _digitado = '';
        _erros = 0;
      });
    } else {
      _finalizar();
    }
  }

  Future<void> _finalizar() async {
    _pararTimer();
    setState(() {
      _concluido = true;
      _mostrarResultado = true;
    });
    await _salvarResultado();
  }

  Future<void> _salvarResultado() async {
    final usuario = ref.read(usuarioAtualProvider);
    if (usuario?.id == null) return;

    final db = ref.read(databaseProvider);
    final totalChars = _licao.textos.fold<int>(0, (s, t) => s + t.length);
    final corretos = totalChars - _errosTotal;

    final sessaoId = await db.salvarSessaoDigitacao(SessaoDigitacao(
      userId: usuario!.id!,
      nivel: widget.nivel,
      subNivel: widget.subNivel,
      tipoExercicio: 'licao',
      wpm: _wpm,
      wpmBruto: _wpm,
      precisao: _precisao,
      totalCaracteres: totalChars,
      caracteresCorretos: corretos.clamp(0, totalChars),
      erros: _errosTotal,
      duracaoSegundos: _segundosDecorridos,
    ));

    // Salvar estatísticas por tecla
    final estatisticas = <EstatisticaTecla>[];
    for (final entry in _acertosPorTecla.entries) {
      final tecla = entry.key;
      final info = _layout.infoTecla(tecla);
      final tempos = _temposPorTecla[tecla] ?? [];
      final tempoMedio = tempos.isNotEmpty
          ? (tempos.fold<int>(0, (s, t) => s + t) / tempos.length).round()
          : 0;

      estatisticas.add(EstatisticaTecla(
        sessaoId: sessaoId,
        userId: usuario.id!,
        tecla: tecla,
        dedo: info?.dedo ?? 'indicador',
        mao: info?.mao ?? 'direita',
        acertos: entry.value,
        erros: _errosPorTecla[tecla] ?? 0,
        tempoMedioMs: tempoMedio,
      ));
    }
    if (estatisticas.isNotEmpty) {
      await db.salvarEstatisticasTeclas(estatisticas);
    }

    ref.invalidate(resumoDigitacaoProvider);
    ref.invalidate(niveisDesbloqueadosProvider);
  }

  String? get _proximaTecla =>
      _digitado.length < _textoAtual.length ? _textoAtual[_digitado.length] : null;

  @override
  Widget build(BuildContext context) {
    if (_mostrarResultado) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: _TelaResultado(
          wpm: _wpm,
          precisao: _precisao,
          erros: _errosTotal,
          duracaoSegundos: _segundosDecorridos,
          licao: _licao,
          onReiniciar: () {
            setState(() {
              _textoIndex = 0;
              _digitado = '';
              _erros = 0;
              _errosTotal = 0;
              _iniciado = false;
              _concluido = false;
              _mostrarResultado = false;
              _segundosDecorridos = 0;
              _acertosPorTecla.clear();
              _errosPorTecla.clear();
              _temposPorTecla.clear();
            });
            _campo.clear();
            _focusNode.requestFocus();
          },
          onProxima: () => context.go('/digitacao'),
        ),
      );
    }

    final layout = ref.watch(layoutTecladoProvider);
    final passos = _proximaTecla != null
        ? layout.passos(_proximaTecla!)
        : const <PassoTecla>[];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          _CampoInvisivel(
            controller: _campo,
            focusNode: _focusNode,
            onChanged: _onTextoMudou,
          ),
          GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              _BarraSuperior(
                titulo: _licao.titulo,
                subtitulo:
                    '${_licao.nivel[0].toUpperCase()}${_licao.nivel.substring(1)} — Lição ${widget.subNivel}',
                onVoltar: () => context.go('/digitacao'),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lateral esquerda — progresso da lição
                    _LateralLicao(
                      licao: _licao,
                      textoIndex: _textoIndex,
                      proximaTecla: _proximaTecla,
                    ),

                    // Centro — teclado, texto e mãos
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Column(
                          children: [
                            // Teclado no topo
                            KeyboardWidget(
                              layout: layout,
                              teclaAtiva:
                                  passos.isNotEmpty ? passos.first.tecla : null,
                              teclaErrada:
                                  _ultimaTeclaErrada.isNotEmpty ? _ultimaTeclaErrada : null,
                              mostrarGuia: true,
                            ),
                            const SizedBox(height: 18),

                            // Texto do exercício no meio
                            _TextoExercicio(
                              layout: layout,
                              texto: _textoAtual,
                              digitado: _digitado,
                              erros: _erros,
                            ),

                            if (passos.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: _DicaSequencia(passos: passos),
                              ),

                            if (!_iniciado)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  'Clique aqui e comece a digitar',
                                  style: AppTextStyles.body
                                      .copyWith(color: AppColors.primary),
                                ).animate(onPlay: (c) => c.repeat(reverse: true))
                                    .fadeIn(duration: 800.ms),
                              ),

                            // Mãos embaixo
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: HandGuideWidget(
                                    layout: layout,
                                    proximaTecla: passos.isNotEmpty
                                        ? passos.first.tecla
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Lateral direita — estatísticas
                    _LateralStats(
                      wpm: _wpm,
                      precisao: _precisao,
                      erros: _errosTotal,
                      segundos: _segundosDecorridos,
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ],
      ),
    );
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

/// Barra superior com logo, título da lição e ações.
class _BarraSuperior extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final VoidCallback onVoltar;

  const _BarraSuperior({
    required this.titulo,
    required this.subtitulo,
    required this.onVoltar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onVoltar,
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            style: IconButton.styleFrom(foregroundColor: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(titulo, style: AppTextStyles.headline3),
              Text(subtitulo, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
            ],
          ),
          const Spacer(),
          const SoundToggleButton(),
        ],
      ),
    );
  }
}

/// Lateral esquerda com o progresso da lição.
class _LateralLicao extends StatelessWidget {
  final Licao licao;
  final int textoIndex;
  final String? proximaTecla;

  const _LateralLicao({
    required this.licao,
    required this.textoIndex,
    this.proximaTecla,
  });

  @override
  Widget build(BuildContext context) {
    final progresso = licao.textos.isEmpty
        ? 0.0
        : (textoIndex + 1) / licao.textos.length;
    final cor = AppTheme.corNivel(licao.nivel);

    return Container(
      width: 92,
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 22),
          // Tecla atual em destaque
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(color: cor, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              proximaTecla == ' ' ? '␣' : (proximaTecla?.toUpperCase() ?? '—'),
              style: AppTextStyles.headline2.copyWith(color: cor),
            ),
          ),
          const SizedBox(height: 18),
          // Barra de progresso vertical
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 8,
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        heightFactor: progresso.clamp(0.02, 1.0),
                        child: AnimatedContainer(
                          duration: 400.ms,
                          decoration: BoxDecoration(
                            color: cor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('${textoIndex + 1}/${licao.textos.length}',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
                const SizedBox(height: 10),
                // Título vertical
                RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    licao.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(fontSize: 10),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lateral direita com cards de estatísticas em tempo real.
class _LateralStats extends StatelessWidget {
  final int wpm;
  final double precisao;
  final int erros;
  final int segundos;

  const _LateralStats({
    required this.wpm,
    required this.precisao,
    required this.erros,
    required this.segundos,
  });

  String get _tempo {
    final m = (segundos ~/ 60).toString().padLeft(2, '0');
    final s = (segundos % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.fromLTRB(12, 20, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          _StatBox(label: 'Velocidade', valor: '$wpm', unidade: 'PPM',
              cor: AppColors.primary),
          const SizedBox(height: 10),
          _StatBox(
            label: 'Precisão',
            valor: precisao.toStringAsFixed(0),
            unidade: '%',
            cor: precisao >= 90
                ? AppColors.success
                : precisao >= 75
                    ? AppColors.warning
                    : AppColors.error,
          ),
          const SizedBox(height: 10),
          _StatBox(label: 'Erros', valor: '$erros', unidade: '',
              cor: erros == 0 ? AppColors.success : AppColors.error),
          const SizedBox(height: 10),
          _StatBox(label: 'Tempo', valor: _tempo, unidade: '',
              cor: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String valor;
  final String unidade;
  final Color cor;

  const _StatBox({
    required this.label,
    required this.valor,
    required this.unidade,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: cor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(valor, style: AppTextStyles.headline2.copyWith(color: cor, fontSize: 21)),
              if (unidade.isNotEmpty) ...[
                const SizedBox(width: 3),
                Text(unidade, style: AppTextStyles.bodySmall
                    .copyWith(color: cor, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Mostra a sequência de teclas de um caractere acentuado: a tecla do acento
/// primeiro, depois a letra.
class _DicaSequencia extends StatelessWidget {
  final List<PassoTecla> passos;

  const _DicaSequencia({required this.passos});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.keyboard_double_arrow_right_rounded,
              color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          for (var i = 0; i < passos.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('depois',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
              ),
              child: Text(
                passos[i].rotulo,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

class _TextoExercicio extends StatelessWidget {
  final KeyboardLayout layout;
  final String texto;
  final String digitado;
  final int erros;

  const _TextoExercicio({
    required this.layout,
    required this.texto,
    required this.digitado,
    required this.erros,
  });

  @override
  Widget build(BuildContext context) {
    // Cor do dedo da letra atual, para o destaque
    final atual = digitado.length < texto.length ? texto[digitado.length] : null;
    final info = atual != null ? layout.infoTecla(atual) : null;
    final corAtual = info != null ? AppTheme.corDedo(info.dedo) : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: erros > 0
              ? AppColors.error.withValues(alpha: 0.45)
              : AppColors.border,
          width: erros > 0 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: List.generate(texto.length, (i) {
            final char = texto[i];
            final ehAtual = i == digitado.length;
            final jaDigitado = i < digitado.length;
            final correto = jaDigitado && digitado[i] == texto[i];

            if (ehAtual) {
              // Letra atual em caixa destacada
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 1),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: corAtual,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: corAtual.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  char == ' ' ? '␣' : char.toUpperCase(),
                  style: AppTextStyles.monoLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
              child: Text(
                char == ' ' ? ' ' : char.toUpperCase(),
                style: AppTextStyles.monoLarge.copyWith(
                  color: jaDigitado
                      ? (correto ? AppColors.textPrimary : AppColors.error)
                      : AppColors.textDisabled,
                  fontWeight: jaDigitado && !correto
                      ? FontWeight.w700
                      : FontWeight.w500,
                  decoration: jaDigitado && !correto
                      ? TextDecoration.underline
                      : null,
                  decorationColor: AppColors.error,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TelaResultado extends StatelessWidget {
  final int wpm;
  final double precisao;
  final int erros;
  final int duracaoSegundos;
  final Licao licao;
  final VoidCallback onReiniciar;
  final VoidCallback onProxima;

  const _TelaResultado({
    required this.wpm,
    required this.precisao,
    required this.erros,
    required this.duracaoSegundos,
    required this.licao,
    required this.onReiniciar,
    required this.onProxima,
  });

  @override
  Widget build(BuildContext context) {
    final passou = wpm >= licao.wpmMeta && precisao >= licao.precisaoMinima;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: passed ? AppColors.success.withValues(alpha: 0.2) : AppColors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                passou ? Icons.emoji_events : Icons.refresh,
                color: passou ? AppColors.success : AppColors.warning,
                size: 40,
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              passou ? 'Parabéns!' : 'Continue Treinando!',
              style: AppTextStyles.headline1,
            ).animate(delay: 200.ms).fadeIn(),
            const SizedBox(height: 8),
            Text(
              passou
                  ? 'Você superou a meta desta lição!'
                  : 'Meta: ${licao.wpmMeta} WPM e ${licao.precisaoMinima}% de precisão',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ).animate(delay: 300.ms).fadeIn(),
            const SizedBox(height: 40),
            Row(
              children: [
                _ResultCard(label: 'WPM', valor: '$wpm', cor: AppColors.accent, meta: licao.wpmMeta, maiorMelhor: true),
                const SizedBox(width: 12),
                _ResultCard(label: 'Precisão', valor: '${precisao.toStringAsFixed(1)}%', cor: AppColors.success, meta: licao.precisaoMinima.toInt(), maiorMelhor: true),
                const SizedBox(width: 12),
                _ResultCard(label: 'Erros', valor: '$erros', cor: AppColors.error, meta: 0, maiorMelhor: false),
              ],
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReiniciar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Repetir'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onProxima,
                    icon: const Icon(Icons.list),
                    label: const Text('Ver Lições'),
                  ),
                ),
              ],
            ).animate(delay: 500.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  bool get passed => wpm >= licao.wpmMeta && precisao >= licao.precisaoMinima;
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;
  final int meta;
  final bool maiorMelhor;

  const _ResultCard({
    required this.label,
    required this.valor,
    required this.cor,
    required this.meta,
    required this.maiorMelhor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(valor, style: AppTextStyles.wpm.copyWith(color: cor, fontSize: 32)),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
