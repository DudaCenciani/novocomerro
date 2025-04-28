import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'visita_model.dart';

class VisitaStorage {
  static final List<Visita> visitas = [];
  static final List<Observacao> observacoes = [];

  static Future<void> adicionarVisita(Visita visita) async {
    visitas.add(visita);
    await _salvarVisitas();
  }

  static Future<void> adicionarObservacao(Observacao observacao) async {
    observacoes.add(observacao);
    await _salvarObservacoes();
  }

  static Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carregar visitas
    final visitasJson = prefs.getStringList('visitas') ?? [];
    visitas.clear();
    visitas.addAll(visitasJson.map((e) => Visita.fromJson(jsonDecode(e))));

    // Carregar observações
    final observacoesJson = prefs.getStringList('observacoes') ?? [];
    observacoes.clear();
    observacoes.addAll(observacoesJson.map((e) => Observacao.fromJson(jsonDecode(e))));
  }

  static Future<void> _salvarVisitas() async {
    final prefs = await SharedPreferences.getInstance();
    final visitasJson = visitas.map((v) => jsonEncode(v.toJson())).toList();
    await prefs.setStringList('visitas', visitasJson);
  }

  static Future<void> _salvarObservacoes() async {
    final prefs = await SharedPreferences.getInstance();
    final observacoesJson = observacoes.map((o) => jsonEncode(o.toJson())).toList();
    await prefs.setStringList('observacoes', observacoesJson);
  }
}
