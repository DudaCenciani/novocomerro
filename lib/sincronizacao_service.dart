import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'visita_storage.dart';
import 'visita_model.dart';



Future<void> sincronizarVisitasOffline() async {
  await VisitaStorage.carregarDados();
  final visitasPendentes = VisitaStorage.visitas.where((v) => !v.sincronizada).toList();

  for (var visita in visitasPendentes) {
    try {
      final visitaMap = visita.toMap();

      // Se a imagem for muito grande para o Firestore, armazene no Firebase Storage
      if (visita.foto != null && visita.foto!.length > 1048487) {
        final nomeArquivo =
            '${visita.dataHora.toIso8601String()}_${visita.agenteSaude}.png';
        final ref = FirebaseStorage.instance.ref().child('fotos_visitas/$nomeArquivo');
        final uploadTask = await ref.putData(visita.foto! as Uint8List);
        final url = await uploadTask.ref.getDownloadURL();
        visitaMap['fotoBase64'] = url; // Salva URL no Firestore
      }

      await FirebaseFirestore.instance.collection('visitas').add(visitaMap);
      visita.sincronizada = true;
      print('✅ Visita sincronizada: ${visita.nomePaciente}');
    } catch (e) {
      print('❌ Erro ao sincronizar visita: $e');
    }
  }

  await VisitaStorage.salvarListaCompleta(VisitaStorage.visitas);
}

Future<void> tentarSincronizarComInternet() async {
  final connectivity = await Connectivity().checkConnectivity();
  if (connectivity != ConnectivityResult.none) {
    print('🌐 Internet detectada. Tentando sincronizar...');
    await sincronizarVisitasOffline();
  } else {
    print('📴 Sem internet. Sincronização adiada.');
  }
}
