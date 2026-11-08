class EstatisticaTecla {
  final int? id;
  final int sessaoId;
  final int userId;
  final String tecla;
  final String dedo;
  final String mao;
  final int acertos;
  final int erros;
  final int tempoMedioMs;

  const EstatisticaTecla({
    this.id,
    required this.sessaoId,
    required this.userId,
    required this.tecla,
    required this.dedo,
    required this.mao,
    this.acertos = 0,
    this.erros = 0,
    this.tempoMedioMs = 0,
  });

  factory EstatisticaTecla.fromMap(Map<String, dynamic> map) {
    return EstatisticaTecla(
      id: map['id'] as int?,
      sessaoId: map['sessao_id'] as int,
      userId: map['user_id'] as int,
      tecla: map['tecla'] as String,
      dedo: map['dedo'] as String,
      mao: map['mao'] as String,
      acertos: (map['acertos'] as int?) ?? 0,
      erros: (map['erros'] as int?) ?? 0,
      tempoMedioMs: (map['tempo_medio_ms'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessao_id': sessaoId,
      'user_id': userId,
      'tecla': tecla,
      'dedo': dedo,
      'mao': mao,
      'acertos': acertos,
      'erros': erros,
      'tempo_medio_ms': tempoMedioMs,
    };
  }
}
