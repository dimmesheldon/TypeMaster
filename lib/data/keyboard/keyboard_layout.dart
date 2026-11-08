// Layouts de teclado suportados: ABNT2 (brasileiro) e os dois americanos.
// Cada layout define o desenho das teclas, o dedo de cada tecla e a sequência
// necessária para produzir caracteres acentuados.

class KeyInfo {
  final String tecla;
  final String dedo; // polegar, indicador, medio, anelar, minimo
  final String mao; // esquerda, direita
  final int linha; // 0=números, 1=QWERTY, 2=ASDF, 3=ZXCV, 4=espaço
  final int coluna;

  const KeyInfo({
    required this.tecla,
    required this.dedo,
    required this.mao,
    required this.linha,
    required this.coluna,
  });
}

/// Uma tecla desenhada no teclado virtual.
class KeyCap {
  final String rotulo;
  final String? rotuloShift;
  final String? tecla; // caractere real; nulo nos modificadores
  final double unidades;
  final bool modificador;

  const KeyCap(
    this.rotulo, {
    this.rotuloShift,
    this.tecla,
    this.unidades = 1.0,
  }) : modificador = false;

  const KeyCap.mod(this.rotulo, {this.unidades = 1.0})
      : rotuloShift = null,
        tecla = null,
        modificador = true;
}

/// Um passo da digitação de um caractere: qual tecla destacar e o que dizer ao aluno.
class PassoTecla {
  final String tecla;
  final String rotulo;
  const PassoTecla(this.tecla, this.rotulo);
}

/// Acento + letra base de cada caractere composto do português.
const Map<String, (String, String)> _decomposicao = {
  'á': ('agudo', 'a'), 'é': ('agudo', 'e'), 'í': ('agudo', 'i'),
  'ó': ('agudo', 'o'), 'ú': ('agudo', 'u'),
  'â': ('circunflexo', 'a'), 'ê': ('circunflexo', 'e'),
  'î': ('circunflexo', 'i'), 'ô': ('circunflexo', 'o'),
  'û': ('circunflexo', 'u'),
  'ã': ('til', 'a'), 'õ': ('til', 'o'), 'ñ': ('til', 'n'),
  'à': ('grave', 'a'), 'è': ('grave', 'e'), 'ì': ('grave', 'i'),
  'ò': ('grave', 'o'), 'ù': ('grave', 'u'),
  'ü': ('trema', 'u'), 'ï': ('trema', 'i'),
  'ç': ('cedilha', 'c'),
};

abstract class KeyboardLayout {
  const KeyboardLayout();

  String get id;
  String get nome;
  String get descricao;

  Map<String, KeyInfo> get teclas;
  List<List<KeyCap>> get linhas;

  /// Tecla morta de cada acento. Vazio quando o layout não usa teclas mortas.
  Map<String, PassoTecla> get teclasMortas;

  /// Caracteres produzidos por uma única combinação (ex.: Option + C → ç no Mac).
  Map<String, PassoTecla> get combinacoesDiretas => const {};

  KeyInfo? infoTecla(String tecla) {
    final k = tecla.toLowerCase();
    final direta = teclas[k];
    if (direta != null) return direta;
    // Caractere composto: o dedo é o da primeira tecla da sequência
    final p = passos(k);
    return p.isEmpty ? null : teclas[p.first.tecla];
  }

  String dedoDaTecla(String tecla) => infoTecla(tecla)?.dedo ?? 'indicador';
  String maoDaTecla(String tecla) => infoTecla(tecla)?.mao ?? 'direita';

  /// Sequência de teclas que o aluno precisa pressionar para produzir [caractere].
  List<PassoTecla> passos(String caractere) {
    if (caractere.isEmpty) return const [];
    final minuscula = caractere.toLowerCase();

    final direta = combinacoesDiretas[minuscula];
    if (direta != null) return [direta];

    if (teclas.containsKey(minuscula)) {
      return [PassoTecla(minuscula, _rotulo(minuscula))];
    }

    final dec = _decomposicao[minuscula];
    if (dec == null) return [PassoTecla(minuscula, caractere)];

    final morta = teclasMortas[dec.$1];
    if (morta == null) return [PassoTecla(dec.$2, dec.$2.toUpperCase())];
    return [morta, PassoTecla(dec.$2, dec.$2.toUpperCase())];
  }

  String _rotulo(String k) => k == ' ' ? 'Espaço' : k.toUpperCase();
}

/// Dedo e mão das teclas comuns a todos os layouts QWERTY.
Map<String, KeyInfo> _baseQwerty() {
  const linhas = [
    (0, ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']),
    (1, ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p']),
    (2, ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l']),
    (3, ['z', 'x', 'c', 'v', 'b', 'n', 'm']),
  ];
  // Dedo por posição na linha (índice 0 = primeira tecla da esquerda)
  const dedos = [
    'minimo', 'anelar', 'medio', 'indicador', 'indicador',
    'indicador', 'indicador', 'medio', 'anelar', 'minimo',
  ];

  final mapa = <String, KeyInfo>{};
  for (final (linha, teclas) in linhas) {
    for (var i = 0; i < teclas.length; i++) {
      mapa[teclas[i]] = KeyInfo(
        tecla: teclas[i],
        dedo: dedos[i],
        mao: i < 5 ? 'esquerda' : 'direita',
        linha: linha,
        coluna: i + 1,
      );
    }
  }
  mapa[' '] = const KeyInfo(
      tecla: ' ', dedo: 'polegar', mao: 'direita', linha: 4, coluna: 5);
  return mapa;
}

KeyInfo _minimoDireita(String tecla, int linha, int coluna) =>
    KeyInfo(tecla: tecla, dedo: 'minimo', mao: 'direita', linha: linha, coluna: coluna);

// ── ABNT2 ────────────────────────────────────────────────────────────────────

class LayoutAbnt2 extends KeyboardLayout {
  const LayoutAbnt2();

  @override
  String get id => 'abnt2';
  @override
  String get nome => 'Brasileiro (ABNT2)';
  @override
  String get descricao =>
      'Teclado nacional, com tecla Ç e acentos próprios (´ e ~).';

  @override
  Map<String, KeyInfo> get teclas => {
        ..._baseQwerty(),
        'ç': _minimoDireita('ç', 2, 10),
        '´': _minimoDireita('´', 1, 11),
        '~': _minimoDireita('~', 2, 11),
        ',': const KeyInfo(tecla: ',', dedo: 'medio', mao: 'direita', linha: 3, coluna: 8),
        '.': const KeyInfo(tecla: '.', dedo: 'anelar', mao: 'direita', linha: 3, coluna: 9),
        ';': _minimoDireita(';', 3, 10),
        '/': _minimoDireita('/', 3, 11),
        '-': _minimoDireita('-', 0, 11),
        '=': _minimoDireita('=', 0, 12),
      };

  @override
  Map<String, PassoTecla> get teclasMortas => const {
        'agudo': PassoTecla('´', '´'),
        'grave': PassoTecla('´', 'Shift + ´'),
        'til': PassoTecla('~', '~'),
        'circunflexo': PassoTecla('~', 'Shift + ~'),
        'trema': PassoTecla('6', 'Shift + 6'),
      };

  @override
  List<List<KeyCap>> get linhas => const [
        [
          KeyCap("'", rotuloShift: '"', tecla: "'"),
          KeyCap('1', rotuloShift: '!', tecla: '1'),
          KeyCap('2', rotuloShift: '@', tecla: '2'),
          KeyCap('3', rotuloShift: '#', tecla: '3'),
          KeyCap('4', rotuloShift: '\$', tecla: '4'),
          KeyCap('5', rotuloShift: '%', tecla: '5'),
          KeyCap('6', rotuloShift: '¨', tecla: '6'),
          KeyCap('7', rotuloShift: '&', tecla: '7'),
          KeyCap('8', rotuloShift: '*', tecla: '8'),
          KeyCap('9', rotuloShift: '(', tecla: '9'),
          KeyCap('0', rotuloShift: ')', tecla: '0'),
          KeyCap('-', rotuloShift: '_', tecla: '-'),
          KeyCap('=', rotuloShift: '+', tecla: '='),
          KeyCap.mod('←', unidades: 2.0),
        ],
        [
          KeyCap.mod('⇥', unidades: 1.5),
          KeyCap('Q', tecla: 'q'), KeyCap('W', tecla: 'w'),
          KeyCap('E', tecla: 'e'), KeyCap('R', tecla: 'r'),
          KeyCap('T', tecla: 't'), KeyCap('Y', tecla: 'y'),
          KeyCap('U', tecla: 'u'), KeyCap('I', tecla: 'i'),
          KeyCap('O', tecla: 'o'), KeyCap('P', tecla: 'p'),
          KeyCap('´', rotuloShift: '`', tecla: '´'),
          KeyCap('[', rotuloShift: '{', tecla: '['),
          KeyCap.mod('⏎', unidades: 1.5),
        ],
        [
          KeyCap.mod('⇪', unidades: 1.75),
          KeyCap('A', tecla: 'a'), KeyCap('S', tecla: 's'),
          KeyCap('D', tecla: 'd'), KeyCap('F', tecla: 'f'),
          KeyCap('G', tecla: 'g'), KeyCap('H', tecla: 'h'),
          KeyCap('J', tecla: 'j'), KeyCap('K', tecla: 'k'),
          KeyCap('L', tecla: 'l'), KeyCap('Ç', tecla: 'ç'),
          KeyCap('~', rotuloShift: '^', tecla: '~'),
          KeyCap(']', rotuloShift: '}', tecla: ']'),
          KeyCap.mod('⏎', unidades: 1.25),
        ],
        [
          KeyCap.mod('⇧', unidades: 1.25),
          KeyCap('\\', rotuloShift: '|', tecla: '\\'),
          KeyCap('Z', tecla: 'z'), KeyCap('X', tecla: 'x'),
          KeyCap('C', tecla: 'c'), KeyCap('V', tecla: 'v'),
          KeyCap('B', tecla: 'b'), KeyCap('N', tecla: 'n'),
          KeyCap('M', tecla: 'm'),
          KeyCap(',', rotuloShift: '<', tecla: ','),
          KeyCap('.', rotuloShift: '>', tecla: '.'),
          KeyCap(';', rotuloShift: ':', tecla: ';'),
          KeyCap('/', rotuloShift: '?', tecla: '/'),
          KeyCap.mod('⇧', unidades: 1.75),
        ],
        [
          KeyCap.mod('Ctrl', unidades: 1.5),
          KeyCap.mod('Alt', unidades: 1.3),
          KeyCap('', tecla: ' ', unidades: 6.5),
          KeyCap.mod('AltGr', unidades: 1.3),
          KeyCap.mod('Ctrl', unidades: 1.5),
        ],
      ];
}

// ── Base americana (ANSI) ────────────────────────────────────────────────────

abstract class _LayoutAnsi extends KeyboardLayout {
  const _LayoutAnsi();

  @override
  Map<String, KeyInfo> get teclas => {
        ..._baseQwerty(),
        ';': _minimoDireita(';', 2, 10),
        "'": _minimoDireita("'", 2, 11),
        '`': const KeyInfo(tecla: '`', dedo: 'minimo', mao: 'esquerda', linha: 0, coluna: 0),
        ',': const KeyInfo(tecla: ',', dedo: 'medio', mao: 'direita', linha: 3, coluna: 8),
        '.': const KeyInfo(tecla: '.', dedo: 'anelar', mao: 'direita', linha: 3, coluna: 9),
        '/': _minimoDireita('/', 3, 10),
        '-': _minimoDireita('-', 0, 11),
        '=': _minimoDireita('=', 0, 12),
        '[': _minimoDireita('[', 1, 11),
        ']': _minimoDireita(']', 1, 12),
      };

  List<KeyCap> get _teclasEspaco;

  @override
  List<List<KeyCap>> get linhas => [
        const [
          KeyCap('`', rotuloShift: '~', tecla: '`'),
          KeyCap('1', rotuloShift: '!', tecla: '1'),
          KeyCap('2', rotuloShift: '@', tecla: '2'),
          KeyCap('3', rotuloShift: '#', tecla: '3'),
          KeyCap('4', rotuloShift: '\$', tecla: '4'),
          KeyCap('5', rotuloShift: '%', tecla: '5'),
          KeyCap('6', rotuloShift: '^', tecla: '6'),
          KeyCap('7', rotuloShift: '&', tecla: '7'),
          KeyCap('8', rotuloShift: '*', tecla: '8'),
          KeyCap('9', rotuloShift: '(', tecla: '9'),
          KeyCap('0', rotuloShift: ')', tecla: '0'),
          KeyCap('-', rotuloShift: '_', tecla: '-'),
          KeyCap('=', rotuloShift: '+', tecla: '='),
          KeyCap.mod('⌫', unidades: 2.0),
        ],
        const [
          KeyCap.mod('⇥', unidades: 1.5),
          KeyCap('Q', tecla: 'q'), KeyCap('W', tecla: 'w'),
          KeyCap('E', tecla: 'e'), KeyCap('R', tecla: 'r'),
          KeyCap('T', tecla: 't'), KeyCap('Y', tecla: 'y'),
          KeyCap('U', tecla: 'u'), KeyCap('I', tecla: 'i'),
          KeyCap('O', tecla: 'o'), KeyCap('P', tecla: 'p'),
          KeyCap('[', rotuloShift: '{', tecla: '['),
          KeyCap(']', rotuloShift: '}', tecla: ']'),
          KeyCap('\\', rotuloShift: '|', tecla: '\\', unidades: 1.5),
        ],
        const [
          KeyCap.mod('⇪', unidades: 1.75),
          KeyCap('A', tecla: 'a'), KeyCap('S', tecla: 's'),
          KeyCap('D', tecla: 'd'), KeyCap('F', tecla: 'f'),
          KeyCap('G', tecla: 'g'), KeyCap('H', tecla: 'h'),
          KeyCap('J', tecla: 'j'), KeyCap('K', tecla: 'k'),
          KeyCap('L', tecla: 'l'),
          KeyCap(';', rotuloShift: ':', tecla: ';'),
          KeyCap("'", rotuloShift: '"', tecla: "'"),
          KeyCap.mod('⏎', unidades: 2.25),
        ],
        const [
          KeyCap.mod('⇧', unidades: 2.25),
          KeyCap('Z', tecla: 'z'), KeyCap('X', tecla: 'x'),
          KeyCap('C', tecla: 'c'), KeyCap('V', tecla: 'v'),
          KeyCap('B', tecla: 'b'), KeyCap('N', tecla: 'n'),
          KeyCap('M', tecla: 'm'),
          KeyCap(',', rotuloShift: '<', tecla: ','),
          KeyCap('.', rotuloShift: '>', tecla: '.'),
          KeyCap('/', rotuloShift: '?', tecla: '/'),
          KeyCap.mod('⇧', unidades: 2.75),
        ],
        _teclasEspaco,
      ];
}

/// Teclado americano do Mac: acentos com a tecla Option.
class LayoutUsMac extends _LayoutAnsi {
  const LayoutUsMac();

  @override
  String get id => 'us_mac';
  @override
  String get nome => 'Americano puro (U.S. / ABC)';
  @override
  String get descricao =>
      'Teclado americano com o layout "U.S." ou "ABC" do macOS, sem teclas '
      'mortas. Os acentos saem com Option: Option + E para ´, Option + N para '
      '~, Option + I para ^ e Option + C para ç.';

  @override
  Map<String, PassoTecla> get teclasMortas => const {
        'agudo': PassoTecla('e', 'Option + E'),
        'grave': PassoTecla('`', 'Option + `'),
        'til': PassoTecla('n', 'Option + N'),
        'circunflexo': PassoTecla('i', 'Option + I'),
        'trema': PassoTecla('u', 'Option + U'),
      };

  @override
  Map<String, PassoTecla> get combinacoesDiretas => const {
        'ç': PassoTecla('c', 'Option + C'),
      };

  @override
  List<KeyCap> get _teclasEspaco => const [
        KeyCap.mod('ctrl', unidades: 1.25),
        KeyCap.mod('⌥', unidades: 1.25),
        KeyCap.mod('⌘', unidades: 1.5),
        KeyCap('', tecla: ' ', unidades: 6.0),
        KeyCap.mod('⌘', unidades: 1.5),
        KeyCap.mod('⌥', unidades: 1.25),
      ];
}

/// Teclado americano internacional: acentos com teclas mortas ' ` ~ ^ ".
class LayoutUsInternacional extends _LayoutAnsi {
  const LayoutUsInternacional();

  @override
  String get id => 'us_intl';
  @override
  String get nome => 'Americano com acentos (Brasileiro – Pro)';
  @override
  String get descricao =>
      'Teclado físico americano com o layout "Brasileiro – Pro" do macOS (ou '
      '"U.S. International" no Windows). O acento vem antes da letra: \' e '
      'depois I para í, Shift + ` e depois A para ã. O ç sai com Option + C.';

  @override
  Map<String, PassoTecla> get teclasMortas => const {
        'agudo': PassoTecla("'", "'"),
        'grave': PassoTecla('`', '`'),
        'til': PassoTecla('`', 'Shift + `'),
        'circunflexo': PassoTecla('6', 'Shift + 6'),
        'trema': PassoTecla("'", 'Shift + \''),
      };

  @override
  Map<String, PassoTecla> get combinacoesDiretas => const {
        'ç': PassoTecla('c', 'Option + C'),
      };

  @override
  List<KeyCap> get _teclasEspaco => const [
        KeyCap.mod('Ctrl', unidades: 1.5),
        KeyCap.mod('Alt', unidades: 1.3),
        KeyCap('', tecla: ' ', unidades: 6.5),
        KeyCap.mod('Alt', unidades: 1.3),
        KeyCap.mod('Ctrl', unidades: 1.5),
      ];
}

// ── Registro ─────────────────────────────────────────────────────────────────

class LayoutsTeclado {
  static const abnt2 = LayoutAbnt2();
  static const usMac = LayoutUsMac();
  static const usIntl = LayoutUsInternacional();

  static const todos = <KeyboardLayout>[abnt2, usIntl, usMac];
  static const padrao = abnt2;

  static KeyboardLayout porId(String? id) =>
      todos.firstWhere((l) => l.id == id, orElse: () => padrao);
}
