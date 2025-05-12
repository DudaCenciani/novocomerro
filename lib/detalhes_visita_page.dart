import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'visita_model.dart';

class DetalhesVisitaPage extends StatelessWidget {
  final Visita visita;

  const DetalhesVisitaPage({super.key, required this.visita});

  String formatarDataHora(DateTime dataHora) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dataHora);
  }

  Future<void> abrirNoMapa(BuildContext context) async {
    final Uri url = Uri.parse(visita.mapaUrl);
    if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o mapa.')),
      );
    }
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
            const SizedBox(height: 12),

            ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Ver no mapa'),
              onPressed: () => abrirNoMapa(context),
            ),

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
