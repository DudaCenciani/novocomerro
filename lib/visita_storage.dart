// lib/visita_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'visita_model.dart';

class Observacao {
  final String nome;
  final String contato;
  final String observacao;
  final DateTime dataHora;

  Observacao({
    required this.nome,
    required this.contato,
    required this.observacao,
    required this.dataHora,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'contato': contato,
      'observacao': observacao,
      'dataHora': dataHora.toIso8601String(),
    };
  }

  factory Observacao.fromMap(Map<String, dynamic> map) {
    return Observacao(
      nome: map['nome'] ?? '',
      contato: map['contato'] ?? '',
      observacao: map['observacao'] ?? '',
      dataHora: DateTime.tryParse(map['dataHora'] ?? '') ?? DateTime.now(),
    );
  }
}

class VisitaStorage {
  static List<Visita> visitas = [];
  static List<Observacao> observacoes = [];

  static Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();

    final visitasString = prefs.getStringList('visitas') ?? [];
    visitas = [];
    for (var v in visitasString) {
      try {
        final map = json.decode(v);
        visitas.add(Visita.fromMap(map));
      } catch (e) {
        debugPrint('Erro ao carregar uma visita: $e');
      }
    }

    final obsString = prefs.getStringList('observacoes') ?? [];
    observacoes = [];
    for (var o in obsString) {
      try {
        final map = json.decode(o);
        observacoes.add(Observacao.fromMap(map));
      } catch (e) {
        debugPrint('Erro ao carregar uma observação: $e');
      }
    }
  }

  static Future<void> salvarVisita(Visita visita) async {
    final prefs = await SharedPreferences.getInstance();
    visitas.add(visita);
    final visitasMapeadas = visitas.map((v) => json.encode(v.toMap())).toList();
    await prefs.setStringList('visitas', visitasMapeadas);
  }

  static Future<void> salvarObservacao(Observacao obs) async {
    final prefs = await SharedPreferences.getInstance();
    observacoes.add(obs);
    final obsMapeadas = observacoes.map((o) => json.encode(o.toMap())).toList();
    await prefs.setStringList('observacoes', obsMapeadas);
  }

  static Future<void> limparTudo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('visitas');
    await prefs.remove('observacoes');
    visitas.clear();
    observacoes.clear();
  }
}
