// lib/sincronizacao_observacoes.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'visita_storage.dart';

Future<void> sincronizarObservacoesOffline() async {
  await VisitaStorage.carregarDados();
  final todas = List<Observacao>.from(VisitaStorage.observacoes);
  final pendentes = todas.where((o) => !o.sincronizada).toList();

  for (var obs in pendentes) {
    try {
      await FirebaseFirestore.instance.collection('observacoes').add(obs.toMap());
      obs.sincronizada = true;
      print('✅ Observação sincronizada: ${obs.nome}');
    } catch (e) {
      print('❌ Falha ao sincronizar observação: $e');
    }
  }

  await VisitaStorage.salvarListaObservacoesCompleta(todas);
}

Future<void> tentarSincronizarObservacoesComInternet() async {
  final connectivity = await Connectivity().checkConnectivity();
  if (connectivity != ConnectivityResult.none) {
    await sincronizarObservacoesOffline();
  }
}
