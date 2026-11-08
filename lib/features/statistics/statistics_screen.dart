import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/usuario_provider.dart';
import '../../core/providers/database_provider.dart';
import '../../core/models/models.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioAtualProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estatísticas'),
            if (usuario != null)
              Text(usuario.nome, style: AppTextStyles.bodySmall),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Digitação'),
            Tab(text: 'Mouse'),
            Tab(text: 'Histórico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TabDigitacao(),
          _TabMouse(),
          _TabHistorico(),
        ],
      ),
    );
  }
}

class _TabDigitacao extends ConsumerWidget {
  const _TabDigitacao();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumoAsync = ref.watch(resumoDigitacaoProvider);
    final progressoAsync = ref.watch(progressoSemanalProvider);
    final teclasAsync = ref.watch(resumoTeclasProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Cards de resumo
        resumoAsync.when(
          data: (r) => Column(
            children: [
              Row(
                children: [
                  _StatBox(label: 'Melhor WPM', valor: '${r.melhorWpm}', cor: AppColors.accent),
                  const SizedBox(width: 12),
                  _StatBox(label: 'Média WPM', valor: r.mediaWpm.toStringAsFixed(0), cor: AppColors.primary),
                  const SizedBox(width: 12),
                  _StatBox(label: 'Precisão Média', valor: '${r.mediaPrecisao.toStringAsFixed(0)}%', cor: AppColors.success),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatBox(label: 'Sessões', valor: '${r.totalSessoes}', cor: AppColors.info),
                  const SizedBox(width: 12),
                  _StatBox(label: 'Total Erros', valor: '${r.totalErros}', cor: AppColors.error),
                  const SizedBox(width: 12),
                  _StatBox(label: 'Caracteres', valor: _formatarNum(r.totalChars), cor: AppColors.textSecondary),
                ],
              ),
            ],
          ).animate().fadeIn(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 32),
        Text('Progresso na Semana', style: AppTextStyles.headline2)
            .animate(delay: 100.ms).fadeIn(),
        const SizedBox(height: 16),
        progressoAsync.when(
          data: (dados) => SizedBox(
            height: 200,
            child: dados.isEmpty
                ? Center(child: Text('Sem dados esta semana', style: AppTextStyles.body))
                : _GraficoSemanal(dados: dados),
          ).animate(delay: 150.ms).fadeIn(),
          loading: () => const SizedBox(height: 200,
              child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox(height: 200),
        ),

        const SizedBox(height: 32),
        Text('Erros por Dedo', style: AppTextStyles.headline2)
            .animate(delay: 200.ms).fadeIn(),
        const SizedBox(height: 16),
        teclasAsync.when(
          data: (t) => _MapaDedos(resumo: t)
              .animate(delay: 250.ms).fadeIn(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  String _formatarNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _TabMouse extends ConsumerWidget {
  const _TabMouse();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumoAsync = ref.watch(resumoMouseProvider);
    final usuario = ref.watch(usuarioAtualProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        resumoAsync.when(
          data: (r) => Column(
            children: [
              Row(
                children: [
                  _StatBox(label: 'Precisão Média', valor: '${r.mediaPrecisao.toStringAsFixed(0)}%', cor: AppColors.accent),
                  const SizedBox(width: 12),
                  _StatBox(label: 'Total Acertos', valor: '${r.totalAcertos}', cor: AppColors.success),
                  const SizedBox(width: 12),
                  _StatBox(label: 'Total Erros', valor: '${r.totalErros}', cor: AppColors.error),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatBox(label: 'Sessões', valor: '${r.totalSessoes}', cor: AppColors.primary),
                  const SizedBox(width: 12),
                  _StatBox(
                    label: 'Tempo de Reação',
                    valor: '${r.mediaReacaoMs.toStringAsFixed(0)}ms',
                    cor: AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  _StatBox(label: 'Mão Mais Rápida', valor: '--', cor: AppColors.info),
                ],
              ),
            ],
          ).animate().fadeIn(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 32),
        if (usuario?.id != null)
          _GraficoSessoesMouseAsync(userId: usuario!.id!),
      ],
    );
  }
}

class _TabHistorico extends ConsumerWidget {
  const _TabHistorico();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioAtualProvider);
    if (usuario?.id == null) {
      return Center(child: Text('Faça login para ver o histórico', style: AppTextStyles.body));
    }

    return FutureBuilder<List<SessaoDigitacao>>(
      future: ref.read(databaseProvider).sessoesDoUsuario(usuario!.id!),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessoes = snap.data ?? [];
        if (sessoes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text('Nenhuma sessão ainda', style: AppTextStyles.body),
                Text('Complete lições para ver seu histórico', style: AppTextStyles.bodySmall),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: sessoes.length,
          itemBuilder: (context, i) {
            final s = sessoes[i];
            return _SessaoCard(sessao: s)
                .animate(delay: Duration(milliseconds: i * 50)).fadeIn();
          },
        );
      },
    );
  }
}

// ── Widgets de apoio ──────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String valor;
  final Color cor;

  const _StatBox({required this.label, required this.valor, required this.cor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valor,
                style: AppTextStyles.headline2.copyWith(color: cor, fontSize: 20)),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _GraficoSemanal extends StatelessWidget {
  final List<Map<String, dynamic>> dados;

  const _GraficoSemanal({required this.dados});

  @override
  Widget build(BuildContext context) {
    final spots = dados.asMap().entries.map((e) {
      final wpm = (e.value['media_wpm'] as num?)?.toDouble() ?? 0;
      return FlSpot(e.key.toDouble(), wpm);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= dados.length) return const SizedBox.shrink();
                final dia = dados[idx]['dia'] as String? ?? '';
                return Text(
                  dia.length >= 5 ? dia.substring(5) : dia,
                  style: AppTextStyles.bodySmall,
                );
              },
              reservedSize: 24,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) => Text(
                '${val.toInt()}',
                style: AppTextStyles.bodySmall,
              ),
              reservedSize: 32,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.accent,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accent.withValues(alpha: 0.1),
            ),
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class _MapaDedos extends StatelessWidget {
  final ResumoTeclas resumo;

  const _MapaDedos({required this.resumo});

  @override
  Widget build(BuildContext context) {
    final dedos = ['minimo', 'anelar', 'medio', 'indicador', 'polegar'];
    final maos = ['esquerda', 'direita'];

    return Column(
      children: [
        // Comparação de mãos
        Row(
          children: maos.map((mao) {
            final erros = mao == 'esquerda' ? resumo.errosEsquerda : resumo.errosDireita;
            final cor = mao == 'esquerda' ? AppColors.maoEsquerda : AppColors.maoDireita;
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: EdgeInsets.only(right: mao == 'esquerda' ? 6 : 0),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      mao == 'esquerda' ? 'Mão Esquerda' : 'Mão Direita',
                      style: AppTextStyles.bodySmall.copyWith(color: cor),
                    ),
                    Text('$erros erros',
                        style: AppTextStyles.headline3.copyWith(color: cor)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Erros por dedo
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              ...maos.expand((mao) => [
                Text(
                  mao == 'esquerda' ? 'Mão Esquerda' : 'Mão Direita',
                  style: AppTextStyles.label.copyWith(
                    color: mao == 'esquerda' ? AppColors.maoEsquerda : AppColors.maoDireita,
                  ),
                ),
                const SizedBox(height: 8),
                ...dedos.map((dedo) {
                  final key = '${mao}_$dedo';
                  final erros = resumo.errosPorDedo[key] ?? 0;
                  final acertos = resumo.acertosPorDedo[key] ?? 0;
                  final total = erros + acertos;
                  final taxa = total > 0 ? erros / total : 0.0;
                  final cor = AppTheme.corDedo(dedo);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 70,
                          child: Text(_nomeDedo(dedo), style: AppTextStyles.bodySmall),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: taxa,
                              backgroundColor: AppColors.bgSurface,
                              valueColor: AlwaysStoppedAnimation<Color>(cor),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 40,
                          child: Text('$erros erros',
                              style: AppTextStyles.bodySmall,
                              textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  String _nomeDedo(String dedo) {
    switch (dedo) {
      case 'polegar': return 'Polegar';
      case 'indicador': return 'Indicador';
      case 'medio': return 'Médio';
      case 'anelar': return 'Anelar';
      case 'minimo': return 'Mínimo';
      default: return dedo;
    }
  }
}

class _GraficoSessoesMouseAsync extends ConsumerWidget {
  final int userId;
  const _GraficoSessoesMouseAsync({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(databaseProvider).sessoesMouseUsuario(userId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessoes = snap.data ?? [];
        if (sessoes.isEmpty) {
          return Center(child: Text('Nenhuma sessão de mouse', style: AppTextStyles.body));
        }

        // Agrupar por tipo de desafio
        final porTipo = <String, int>{};
        for (final s in sessoes) {
          porTipo[s.tipoDesafio] = (porTipo[s.tipoDesafio] ?? 0) + s.acertos;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Acertos por Tipo de Desafio', style: AppTextStyles.headline2),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, _) {
                          final keys = porTipo.keys.toList();
                          if (val.toInt() >= keys.length) return const SizedBox.shrink();
                          return Text(keys[val.toInt()],
                              style: AppTextStyles.bodySmall.copyWith(fontSize: 10));
                        },
                        reservedSize: 24,
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: porTipo.entries.indexed.map((entry) {
                    final i = entry.$1;
                    final e = entry.$2;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.toDouble(),
                          color: AppColors.accent,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SessaoCard extends StatelessWidget {
  final SessaoDigitacao sessao;

  const _SessaoCard({required this.sessao});

  @override
  Widget build(BuildContext context) {
    final cor = AppTheme.corNivel(sessao.nivel);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sessao.nivelLabel} ${sessao.subNivel} — ${sessao.tipoExercicio}',
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  '${sessao.realizadaEm.day}/${sessao.realizadaEm.month}/${sessao.realizadaEm.year}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${sessao.wpm} WPM',
                  style: AppTextStyles.body.copyWith(color: AppColors.accent)),
              Text('${sessao.precisao.toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }
}
