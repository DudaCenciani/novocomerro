import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'visita_model.dart';
import 'visita_storage.dart';

class VisualizarVisitaPage extends StatelessWidget {
  final Uint8List assinatura;
  final DateTime dataHora;
  final String endereco;
  final Uint8List? foto;

  const VisualizarVisitaPage({
    super.key,
    required this.assinatura,
    required this.dataHora,
    required this.endereco,
    this.foto,
  });

  String formatarDataHora(DateTime dataHora) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dataHora);
  }

  void _confirmarVisita(BuildContext context) {
    final visita = Visita(
      assinatura: assinatura,
      latitude: 0,
      longitude: 0,
      endereco: endereco,
      dataHora: dataHora,
      foto: foto,
    );

    VisitaStorage.adicionarVisita(visita);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visita salva no histórico!')),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('Visita Realizada'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data/Hora: ${formatarDataHora(dataHora)}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Endereço: $endereco', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('Assinatura:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Image.memory(
              assinatura,
              height: 200,
            ),
            const SizedBox(height: 20),
            if (foto != null) ...[
              const Text('Foto:', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Image.memory(
                foto!,
                height: 200,
              ),
            ],
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => _confirmarVisita(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: const TextStyle(fontSize: 22),
                  ),
                  child: const Text('Confirmar e Salvar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
