class SessaoMouse {
  final int? id;
  final int userId;
  final String nivel;
  final int subNivel;
  final String tipoDesafio;
  final int acertos;
  final int erros;
  final double precisao;
  final int tempoReacaoMedioMs;
  final int duracaoSegundos;
  final DateTime realizadaEm;

  SessaoMouse({
    this.id,
    required this.userId,
    required this.nivel,
    required this.subNivel,
    required this.tipoDesafio,
    this.acertos = 0,
    this.erros = 0,
    this.precisao = 0.0,
    this.tempoReacaoMedioMs = 0,
    this.duracaoSegundos = 0,
    DateTime? realizadaEm,
  }) : realizadaEm = realizadaEm ?? DateTime.now();

  factory SessaoMouse.fromMap(Map<String, dynamic> map) {
    return SessaoMouse(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      nivel: map['nivel'] as String,
      subNivel: map['sub_nivel'] as int,
      tipoDesafio: map['tipo_desafio'] as String,
      acertos: (map['acertos'] as int?) ?? 0,
      erros: (map['erros'] as int?) ?? 0,
      precisao: (map['precisao'] as num?)?.toDouble() ?? 0.0,
      tempoReacaoMedioMs: (map['tempo_reacao_medio_ms'] as int?) ?? 0,
      duracaoSegundos: (map['duracao_segundos'] as int?) ?? 0,
      realizadaEm: DateTime.tryParse(map['realizada_em'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'nivel': nivel,
      'sub_nivel': subNivel,
      'tipo_desafio': tipoDesafio,
      'acertos': acertos,
      'erros': erros,
      'precisao': precisao,
      'tempo_reacao_medio_ms': tempoReacaoMedioMs,
      'duracao_segundos': duracaoSegundos,
    };
  }
}

class EstatisticaClique {
  final int? id;
  final int sessaoId;
  final int userId;
  final String tipoClique;
  final String mao;
  final int acertos;
  final int erros;
  final int tempoReacaoMedioMs;

  const EstatisticaClique({
    this.id,
    required this.sessaoId,
    required this.userId,
    required this.tipoClique,
    required this.mao,
    this.acertos = 0,
    this.erros = 0,
    this.tempoReacaoMedioMs = 0,
  });

  factory EstatisticaClique.fromMap(Map<String, dynamic> map) {
    return EstatisticaClique(
      id: map['id'] as int?,
      sessaoId: map['sessao_id'] as int,
      userId: map['user_id'] as int,
      tipoClique: map['tipo_clique'] as String,
      mao: map['mao'] as String,
      acertos: (map['acertos'] as int?) ?? 0,
      erros: (map['erros'] as int?) ?? 0,
      tempoReacaoMedioMs: (map['tempo_reacao_medio_ms'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessao_id': sessaoId,
      'user_id': userId,
      'tipo_clique': tipoClique,
      'mao': mao,
      'acertos': acertos,
      'erros': erros,
      'tempo_reacao_medio_ms': tempoReacaoMedioMs,
    };
  }
}
