import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import 'database_provider.dart';

// Usuário logado atualmente
final usuarioAtualProvider = StateProvider<Usuario?>((ref) => null);

// Lista de todos os usuários
final listaUsuariosProvider = FutureProvider<List<Usuario>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.listarUsuarios();
});

// Resumo de digitação do usuário atual
final resumoDigitacaoProvider = FutureProvider<ResumoDigitacao>((ref) async {
  final usuario = ref.watch(usuarioAtualProvider);
  if (usuario?.id == null) return ResumoDigitacao.empty;
  final db = ref.read(databaseProvider);
  return db.resumoDigitacaoUsuario(usuario!.id!);
});

// Resumo de mouse do usuário atual
final resumoMouseProvider = FutureProvider<ResumoMouse>((ref) async {
  final usuario = ref.watch(usuarioAtualProvider);
  if (usuario?.id == null) return ResumoMouse.empty;
  final db = ref.read(databaseProvider);
  return db.resumoMouseUsuario(usuario!.id!);
});

// Progresso semanal
final progressoSemanalProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final usuario = ref.watch(usuarioAtualProvider);
  if (usuario?.id == null) return [];
  final db = ref.read(databaseProvider);
  return db.progressoSemanal(usuario!.id!);
});

// Resumo de teclas
final resumoTeclasProvider = FutureProvider<ResumoTeclas>((ref) async {
  final usuario = ref.watch(usuarioAtualProvider);
  if (usuario?.id == null) return ResumoTeclas.empty;
  final db = ref.read(databaseProvider);
  return db.resumoTeclasUsuario(usuario!.id!);
});

// Níveis desbloqueados
final niveisDesbloqueadosProvider = FutureProvider<Map<String, int>>((ref) async {
  final usuario = ref.watch(usuarioAtualProvider);
  if (usuario?.id == null) return {};
  final db = ref.read(databaseProvider);
  return db.nivelMaximoDesbloqueado(usuario!.id!);
});
