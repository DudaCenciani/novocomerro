
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'visita_model.dart';

class VisualizarVisitaPage extends StatelessWidget {
  final Visita visita;

  const VisualizarVisitaPage({super.key, required this.visita});

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
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Paciente: ${visita.nomePaciente}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Agente de Saúde: ${visita.agenteSaude}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Data/Hora: ${formatarDataHora(visita.dataHora)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Endereço: ${visita.endereco}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Latitude: ${visita.latitude}', style: const TextStyle(fontSize: 14)),
            Text('Longitude: ${visita.longitude}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            const Text('Foto:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            visita.foto != null
                ? Image.memory(visita.foto!, height: 200)
                : const Text('Sem foto registrada.'),
            const SizedBox(height: 16),
            const Text('Assinatura:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Container(
              height: 150,
              decoration: BoxDecoration(border: Border.all()),
              child: visita.assinatura.isNotEmpty
                  ? Image.memory(
                      visita.assinatura,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('Erro ao exibir assinatura.')),
                    )
                  : const Center(child: Text('Assinatura vazia.')),
            ),
          ],
        ),
      ),
    );
  }
}
