class SessaoDigitacao {
  final int? id;
  final int userId;
  final String nivel;
  final int subNivel;
  final String tipoExercicio;
  final String layoutTeclado;
  final int wpm;
  final int wpmBruto;
  final double precisao;
  final int totalCaracteres;
  final int caracteresCorretos;
  final int erros;
  final int duracaoSegundos;
  final DateTime realizadaEm;

  SessaoDigitacao({
    this.id,
    required this.userId,
    required this.nivel,
    required this.subNivel,
    required this.tipoExercicio,
    this.layoutTeclado = 'ABNT2',
    required this.wpm,
    this.wpmBruto = 0,
    required this.precisao,
    required this.totalCaracteres,
    required this.caracteresCorretos,
    required this.erros,
    required this.duracaoSegundos,
    DateTime? realizadaEm,
  }) : realizadaEm = realizadaEm ?? DateTime.now();

  factory SessaoDigitacao.fromMap(Map<String, dynamic> map) {
    return SessaoDigitacao(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      nivel: map['nivel'] as String,
      subNivel: map['sub_nivel'] as int,
      tipoExercicio: map['tipo_exercicio'] as String,
      layoutTeclado: (map['layout_teclado'] as String?) ?? 'ABNT2',
      wpm: (map['wpm'] as int?) ?? 0,
      wpmBruto: (map['wpm_bruto'] as int?) ?? 0,
      precisao: (map['precisao'] as num?)?.toDouble() ?? 0.0,
      totalCaracteres: (map['total_caracteres'] as int?) ?? 0,
      caracteresCorretos: (map['caracteres_corretos'] as int?) ?? 0,
      erros: (map['erros'] as int?) ?? 0,
      duracaoSegundos: (map['duracao_segundos'] as int?) ?? 0,
      realizadaEm: DateTime.tryParse(map['realizada_em'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'nivel': nivel,
      'sub_nivel': subNivel,
      'tipo_exercicio': tipoExercicio,
      'layout_teclado': layoutTeclado,
      'wpm': wpm,
      'wpm_bruto': wpmBruto,
      'precisao': precisao,
      'total_caracteres': totalCaracteres,
      'caracteres_corretos': caracteresCorretos,
      'erros': erros,
      'duracao_segundos': duracaoSegundos,
    };
  }

  String get nivelLabel {
    switch (nivel) {
      case 'iniciante': return 'Iniciante';
      case 'medio': return 'Médio';
      case 'avancado': return 'Avançado';
      case 'hardcore': return 'Hardcore';
      default: return nivel;
    }
  }
}
