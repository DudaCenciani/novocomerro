import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Map<String, dynamic> toMap() => {
    'nome': nome,
    'contato': contato,
    'observacao': observacao,
    'dataHora': dataHora.toIso8601String(),
  };

  factory Observacao.fromMap(Map<String, dynamic> map) => Observacao(
    nome: map['nome'] ?? '',
    contato: map['contato'] ?? '',
    observacao: map['observacao'] ?? '',
    dataHora: DateTime.tryParse(map['dataHora'] ?? '') ?? DateTime.now(),
  );
}

class VisitaStorage {
  static List<Visita> visitas = [];
  static List<Observacao> observacoes = [];

  static Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    final visitasString = prefs.getStringList('visitas') ?? [];
    visitas = visitasString.map((v) => Visita.fromMap(json.decode(v))).toList();

    final obsString = prefs.getStringList('observacoes') ?? [];
    observacoes = obsString.map((o) => Observacao.fromMap(json.decode(o))).toList();
  }

  static Future<void> salvarVisita(Visita visita) async {
    final prefs = await SharedPreferences.getInstance();
    visitas.add(visita);
    final visitasMapeadas = visitas.map((v) => json.encode(v.toMap())).toList();
    await prefs.setStringList('visitas', visitasMapeadas);

    await FirebaseFirestore.instance.collection('visitas').add(visita.toMap());
  }

  static Future<void> salvarObservacao(Observacao obs) async {
    final prefs = await SharedPreferences.getInstance();
    observacoes.add(obs);
    final obsMapeadas = observacoes.map((o) => json.encode(o.toMap())).toList();
    await prefs.setStringList('observacoes', obsMapeadas);

    await FirebaseFirestore.instance.collection('observacoes').add(obs.toMap());
  }

  static Future<void> limparTudo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('visitas');
    await prefs.remove('observacoes');
    visitas.clear();
    observacoes.clear();
  }
}
