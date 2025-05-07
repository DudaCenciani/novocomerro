import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'visita_model.dart';

class Observacao {
  final String nome;
  final String contato;
  final String observacao;
  final DateTime dataHora;
  bool sincronizada;

  Observacao({
    required this.nome,
    required this.contato,
    required this.observacao,
    required this.dataHora,
    this.sincronizada = false,
  });

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'contato': contato,
        'observacao': observacao,
        'dataHora': dataHora.toIso8601String(),
        'sincronizada': sincronizada,
      };

  factory Observacao.fromMap(Map<String, dynamic> map) => Observacao(
        nome: map['nome'] ?? '',
        contato: map['contato'] ?? '',
        observacao: map['observacao'] ?? '',
        dataHora: DateTime.tryParse(map['dataHora'] ?? '') ?? DateTime.now(),
        sincronizada: map['sincronizada'] ?? false,
      );
}

class VisitaStorage {
  static List<Visita> visitas = [];
  static List<Observacao> observacoes = [];

  static Future<void> carregarDados() async {
    final prefs = await SharedPreferences.getInstance();

    final visitasString = prefs.getStringList('visitas') ?? [];
    visitas = visitasString.map((v) {
      try {
        return Visita.fromMap(json.decode(v));
      } catch (e) {
        print('Erro ao carregar visita: $e');
        return null;
      }
    }).whereType<Visita>().toList();

    final obsString = prefs.getStringList('observacoes') ?? [];
    observacoes = obsString.map((o) {
      try {
        return Observacao.fromMap(json.decode(o));
      } catch (e) {
        print('Erro ao carregar observação: $e');
        return null;
      }
    }).whereType<Observacao>().toList();
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

  static Future<void> salvarListaCompleta(List<Visita> novaLista) async {
    final prefs = await SharedPreferences.getInstance();
    visitas = novaLista;
    final visitasMapeadas = visitas.map((v) => json.encode(v.toMap())).toList();
    await prefs.setStringList('visitas', visitasMapeadas);
  }

  static Future<void> salvarListaObservacoesCompleta(List<Observacao> novaLista) async {
    final prefs = await SharedPreferences.getInstance();
    observacoes = novaLista;
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

  static Future<void> sincronizarVisitas() async {
    final conectividade = await Connectivity().checkConnectivity();
    if (conectividade == ConnectivityResult.none) {
      print('📴 Sem conexão. Sincronização adiada.');
      return;
    }

    print('🌐 Internet detectada. Tentando sincronizar...');

    final visitasNaoSincronizadas = visitas.where((v) => !v.sincronizada).toList();

    for (var visita in visitasNaoSincronizadas) {
      try {
        final fotoBytes = visita.fotoBase64 != null ? base64Decode(visita.fotoBase64!) : null;
        if (fotoBytes != null && fotoBytes.lengthInBytes > 1000000) {
          print('⚠️ Foto muito grande (${fotoBytes.lengthInBytes} bytes), ignorando essa visita.');
          continue;
        }

        await FirebaseFirestore.instance.collection('visitas').add(visita.toMap());

        print('✅ Visita sincronizada com Firebase!');
        visita.sincronizada = true;
      } catch (e) {
        print('❌ Erro ao sincronizar visita: $e');
      }
    }

    await salvarListaCompleta(visitas);
  }
}
