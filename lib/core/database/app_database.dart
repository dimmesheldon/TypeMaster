import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/models.dart';

class AppDatabase {
  static AppDatabase? _instance;
  static Database? _db;

  AppDatabase._();

  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'typemaster.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        avatar_cor TEXT DEFAULT '#6C63FF',
        criado_em TEXT DEFAULT (datetime('now')),
        total_sessoes INTEGER DEFAULT 0,
        total_minutos INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sessoes_digitacao (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nivel TEXT NOT NULL,
        sub_nivel INTEGER NOT NULL,
        tipo_exercicio TEXT NOT NULL,
        layout_teclado TEXT DEFAULT 'ABNT2',
        wpm INTEGER DEFAULT 0,
        wpm_bruto INTEGER DEFAULT 0,
        precisao REAL DEFAULT 0.0,
        total_caracteres INTEGER DEFAULT 0,
        caracteres_corretos INTEGER DEFAULT 0,
        erros INTEGER DEFAULT 0,
        duracao_segundos INTEGER DEFAULT 0,
        realizada_em TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE estatisticas_teclas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessao_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        tecla TEXT NOT NULL,
        dedo TEXT NOT NULL,
        mao TEXT NOT NULL,
        acertos INTEGER DEFAULT 0,
        erros INTEGER DEFAULT 0,
        tempo_medio_ms INTEGER DEFAULT 0,
        FOREIGN KEY (sessao_id) REFERENCES sessoes_digitacao(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE sessoes_mouse (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nivel TEXT NOT NULL,
        sub_nivel INTEGER NOT NULL,
        tipo_desafio TEXT NOT NULL,
        acertos INTEGER DEFAULT 0,
        erros INTEGER DEFAULT 0,
        precisao REAL DEFAULT 0.0,
        tempo_reacao_medio_ms INTEGER DEFAULT 0,
        duracao_segundos INTEGER DEFAULT 0,
        realizada_em TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE estatisticas_cliques (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sessao_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        tipo_clique TEXT NOT NULL,
        mao TEXT NOT NULL,
        acertos INTEGER DEFAULT 0,
        erros INTEGER DEFAULT 0,
        tempo_reacao_medio_ms INTEGER DEFAULT 0,
        FOREIGN KEY (sessao_id) REFERENCES sessoes_mouse(id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE CASCADE
      )
    ''');
  }

  // ── Usuários ─────────────────────────────────────────────────────────────

  Future<List<Usuario>> listarUsuarios() async {
    final d = await db;
    final rows = await d.query('usuarios', orderBy: 'nome ASC');
    return rows.map(Usuario.fromMap).toList();
  }

  Future<Usuario?> buscarUsuario(int id) async {
    final d = await db;
    final rows = await d.query('usuarios', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Usuario.fromMap(rows.first);
  }

  Future<int> criarUsuario(Usuario u) async {
    final d = await db;
    return d.insert('usuarios', u.toMap());
  }

  Future<void> atualizarUsuario(Usuario u) async {
    final d = await db;
    await d.update('usuarios', u.toMap(), where: 'id = ?', whereArgs: [u.id]);
  }

  Future<void> deletarUsuario(int id) async {
    final d = await db;
    await d.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  // ── Sessões de Digitação ──────────────────────────────────────────────────

  Future<int> salvarSessaoDigitacao(SessaoDigitacao s) async {
    final d = await db;
    final id = await d.insert('sessoes_digitacao', s.toMap());
    await d.rawUpdate(
      'UPDATE usuarios SET total_sessoes = total_sessoes + 1, total_minutos = total_minutos + ? WHERE id = ?',
      [(s.duracaoSegundos / 60).ceil(), s.userId],
    );
    return id;
  }

  Future<List<SessaoDigitacao>> sessoesDoUsuario(int userId) async {
    final d = await db;
    final rows = await d.query(
      'sessoes_digitacao',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'realizada_em DESC',
      limit: 100,
    );
    return rows.map(SessaoDigitacao.fromMap).toList();
  }

  Future<SessaoDigitacao?> melhorWpmUsuario(int userId) async {
    final d = await db;
    final rows = await d.query(
      'sessoes_digitacao',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'wpm DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SessaoDigitacao.fromMap(rows.first);
  }

  Future<ResumoDigitacao> resumoDigitacaoUsuario(int userId) async {
    final d = await db;
    final result = await d.rawQuery('''
      SELECT
        COUNT(*) as total_sessoes,
        MAX(wpm) as melhor_wpm,
        AVG(wpm) as media_wpm,
        AVG(precisao) as media_precisao,
        SUM(erros) as total_erros,
        SUM(total_caracteres) as total_chars
      FROM sessoes_digitacao
      WHERE user_id = ?
    ''', [userId]);
    return ResumoDigitacao.fromMap(result.first);
  }

  // ── Estatísticas de Teclas ─────────────────────────────────────────────────

  Future<void> salvarEstatisticasTeclas(List<EstatisticaTecla> stats) async {
    final d = await db;
    final batch = d.batch();
    for (final s in stats) {
      batch.insert('estatisticas_teclas', s.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<EstatisticaTecla>> estatTeclasUsuario(int userId) async {
    final d = await db;
    final rows = await d.query(
      'estatisticas_teclas',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return rows.map(EstatisticaTecla.fromMap).toList();
  }

  Future<ResumoTeclas> resumoTeclasUsuario(int userId) async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT mao, dedo, SUM(erros) as total_erros, SUM(acertos) as total_acertos,
             AVG(tempo_medio_ms) as tempo_medio
      FROM estatisticas_teclas
      WHERE user_id = ?
      GROUP BY mao, dedo
    ''', [userId]);
    return ResumoTeclas.fromRows(rows);
  }

  // ── Sessões de Mouse ───────────────────────────────────────────────────────

  Future<int> salvarSessaoMouse(SessaoMouse s) async {
    final d = await db;
    return d.insert('sessoes_mouse', s.toMap());
  }

  Future<List<SessaoMouse>> sessoesMouseUsuario(int userId) async {
    final d = await db;
    final rows = await d.query(
      'sessoes_mouse',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'realizada_em DESC',
      limit: 100,
    );
    return rows.map(SessaoMouse.fromMap).toList();
  }

  Future<ResumoMouse> resumoMouseUsuario(int userId) async {
    final d = await db;
    final result = await d.rawQuery('''
      SELECT
        COUNT(*) as total_sessoes,
        AVG(precisao) as media_precisao,
        SUM(acertos) as total_acertos,
        SUM(erros) as total_erros,
        AVG(tempo_reacao_medio_ms) as media_reacao_ms
      FROM sessoes_mouse
      WHERE user_id = ?
    ''', [userId]);
    return ResumoMouse.fromMap(result.first);
  }

  // ── Progresso por Nível ───────────────────────────────────────────────────

  Future<Map<String, int>> nivelMaximoDesbloqueado(int userId) async {
    final d = await db;
    final result = await d.rawQuery('''
      SELECT nivel, MAX(sub_nivel) as max_sub
      FROM sessoes_digitacao
      WHERE user_id = ? AND precisao >= 85
      GROUP BY nivel
    ''', [userId]);
    final map = <String, int>{};
    for (final row in result) {
      map[row['nivel'] as String] = (row['max_sub'] as int?) ?? 1;
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> progressoSemanal(int userId) async {
    final d = await db;
    return d.rawQuery('''
      SELECT date(realizada_em) as dia, AVG(wpm) as media_wpm, AVG(precisao) as media_precisao
      FROM sessoes_digitacao
      WHERE user_id = ? AND realizada_em >= datetime('now', '-7 days')
      GROUP BY date(realizada_em)
      ORDER BY dia ASC
    ''', [userId]);
  }
}
