class ResumoDigitacao {
  final int totalSessoes;
  final int melhorWpm;
  final double mediaWpm;
  final double mediaPrecisao;
  final int totalErros;
  final int totalChars;

  const ResumoDigitacao({
    this.totalSessoes = 0,
    this.melhorWpm = 0,
    this.mediaWpm = 0,
    this.mediaPrecisao = 0,
    this.totalErros = 0,
    this.totalChars = 0,
  });

  factory ResumoDigitacao.fromMap(Map<String, dynamic> map) {
    return ResumoDigitacao(
      totalSessoes: (map['total_sessoes'] as int?) ?? 0,
      melhorWpm: (map['melhor_wpm'] as int?) ?? 0,
      mediaWpm: (map['media_wpm'] as num?)?.toDouble() ?? 0,
      mediaPrecisao: (map['media_precisao'] as num?)?.toDouble() ?? 0,
      totalErros: (map['total_erros'] as int?) ?? 0,
      totalChars: (map['total_chars'] as int?) ?? 0,
    );
  }

  static const empty = ResumoDigitacao();
}

class ResumoMouse {
  final int totalSessoes;
  final double mediaPrecisao;
  final int totalAcertos;
  final int totalErros;
  final double mediaReacaoMs;

  const ResumoMouse({
    this.totalSessoes = 0,
    this.mediaPrecisao = 0,
    this.totalAcertos = 0,
    this.totalErros = 0,
    this.mediaReacaoMs = 0,
  });

  factory ResumoMouse.fromMap(Map<String, dynamic> map) {
    return ResumoMouse(
      totalSessoes: (map['total_sessoes'] as int?) ?? 0,
      mediaPrecisao: (map['media_precisao'] as num?)?.toDouble() ?? 0,
      totalAcertos: (map['total_acertos'] as int?) ?? 0,
      totalErros: (map['total_erros'] as int?) ?? 0,
      mediaReacaoMs: (map['media_reacao_ms'] as num?)?.toDouble() ?? 0,
    );
  }

  static const empty = ResumoMouse();
}

class ResumoTeclas {
  final Map<String, int> errosPorDedo; // 'esquerda_indicador': 12
  final Map<String, int> acertosPorDedo;
  final Map<String, double> tempoPorDedo;
  final int errosEsquerda;
  final int errosDireita;

  const ResumoTeclas({
    this.errosPorDedo = const {},
    this.acertosPorDedo = const {},
    this.tempoPorDedo = const {},
    this.errosEsquerda = 0,
    this.errosDireita = 0,
  });

  factory ResumoTeclas.fromRows(List<Map<String, dynamic>> rows) {
    final errosPorDedo = <String, int>{};
    final acertosPorDedo = <String, int>{};
    final tempoPorDedo = <String, double>{};
    int errosE = 0, errosD = 0;

    for (final row in rows) {
      final mao = row['mao'] as String;
      final dedo = row['dedo'] as String;
      final key = '${mao}_$dedo';
      final erros = (row['total_erros'] as int?) ?? 0;
      final acertos = (row['total_acertos'] as int?) ?? 0;
      final tempo = (row['tempo_medio'] as num?)?.toDouble() ?? 0;

      errosPorDedo[key] = erros;
      acertosPorDedo[key] = acertos;
      tempoPorDedo[key] = tempo;

      if (mao == 'esquerda') errosE += erros;
      if (mao == 'direita') errosD += erros;
    }

    return ResumoTeclas(
      errosPorDedo: errosPorDedo,
      acertosPorDedo: acertosPorDedo,
      tempoPorDedo: tempoPorDedo,
      errosEsquerda: errosE,
      errosDireita: errosD,
    );
  }

  static const empty = ResumoTeclas();
}
