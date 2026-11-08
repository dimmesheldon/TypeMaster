import 'package:flutter/material.dart';

class Usuario {
  final int? id;
  final String nome;
  final String avatarCor;
  final DateTime criadoEm;
  final int totalSessoes;
  final int totalMinutos;

  Usuario({
    this.id,
    required this.nome,
    this.avatarCor = '#6C63FF',
    DateTime? criadoEm,
    this.totalSessoes = 0,
    this.totalMinutos = 0,
  }) : criadoEm = criadoEm ?? DateTime.now();

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      avatarCor: (map['avatar_cor'] as String?) ?? '#6C63FF',
      criadoEm: DateTime.tryParse(map['criado_em'] as String? ?? '') ?? DateTime.now(),
      totalSessoes: (map['total_sessoes'] as int?) ?? 0,
      totalMinutos: (map['total_minutos'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'nome': nome,
      'avatar_cor': avatarCor,
      'total_sessoes': totalSessoes,
      'total_minutos': totalMinutos,
    };
    if (id != null) m['id'] = id;
    return m;
  }

  Color get cor {
    final hex = avatarCor.replaceAll('#', '');
    final value = int.tryParse('FF$hex', radix: 16) ?? 0xFF6C63FF;
    return Color(value);
  }

  String get iniciais {
    final partes = nome.trim().split(' ');
    if (partes.length == 1) return partes[0].substring(0, 1).toUpperCase();
    return '${partes[0][0]}${partes.last[0]}'.toUpperCase();
  }

  Usuario copyWith({
    int? id,
    String? nome,
    String? avatarCor,
    DateTime? criadoEm,
    int? totalSessoes,
    int? totalMinutos,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      avatarCor: avatarCor ?? this.avatarCor,
      criadoEm: criadoEm ?? this.criadoEm,
      totalSessoes: totalSessoes ?? this.totalSessoes,
      totalMinutos: totalMinutos ?? this.totalMinutos,
    );
  }
}
