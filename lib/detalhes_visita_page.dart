import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'visita_model.dart'; // Importa o modelo

class DetalhesVisitaPage extends StatelessWidget {
  final Visita visita;

  const DetalhesVisitaPage({super.key, required this.visita});

  String formatarDataHora(DateTime dataHora) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dataHora);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Visita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('Data/Hora: ${formatarDataHora(visita.dataHora)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Latitude: ${visita.latitude}', style: const TextStyle(fontSize: 16)),
            Text('Longitude: ${visita.longitude}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Endereço:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(visita.endereco, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            if (visita.assinatura.isNotEmpty) ...[
              const Text('Assinatura:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Image.memory(visita.assinatura),
            ],
            const SizedBox(height: 16),
            if (visita.foto != null) ...[
              const Text('Foto tirada:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Image.memory(visita.foto!),
            ],
          ],
        ),
      ),
    );
  }
}
