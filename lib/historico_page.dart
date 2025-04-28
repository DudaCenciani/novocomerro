import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'visita_model.dart';
import 'visita_storage.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  String _termoBusca = '';
  DateTime? _dataSelecionada;

  String formatarDataHora(DateTime dataHora) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dataHora);
  }

  bool mesmaData(DateTime data1, DateTime data2) {
    return data1.year == data2.year &&
           data1.month == data2.month &&
           data1.day == data2.day;
  }

  @override
  Widget build(BuildContext context) {
    final visitas = List<Visita>.from(VisitaStorage.visitas)
      ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
    final observacoes = List<Observacao>.from(VisitaStorage.observacoes)
      ..sort((a, b) => b.dataHora.compareTo(a.dataHora));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Histórico'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Visitas'),
              Tab(text: 'Observações'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _termoBusca = value.toLowerCase();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selecionarData,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _dataSelecionada != null
                            ? DateFormat('dd/MM/yyyy').format(_dataSelecionada!)
                            : 'Filtrar por Data',
                      ),
                    ),
                  ),
                  if (_dataSelecionada != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _dataSelecionada = null;
                        });
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _exportarVisitasCSV,
                      child: const Text('Exportar Visitas'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _exportarObservacoesCSV,
                      child: const Text('Exportar Observações'),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Aba de Visitas
                  ListView.builder(
                    itemCount: visitas.length,
                    itemBuilder: (context, index) {
                      final visita = visitas[index];

                      if (_termoBusca.isNotEmpty &&
                          !(visita.endereco.toLowerCase().contains(_termoBusca))) {
                        return const SizedBox.shrink();
                      }
                      if (_dataSelecionada != null &&
                          !mesmaData(visita.dataHora, _dataSelecionada!)) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Data/Hora: ${formatarDataHora(visita.dataHora)}'),
                              const SizedBox(height: 8),
                              Text('Latitude: ${visita.latitude}'),
                              Text('Longitude: ${visita.longitude}'),
                              Text('Endereço: ${visita.endereco}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Aba de Observações
                  ListView.builder(
                    itemCount: observacoes.length,
                    itemBuilder: (context, index) {
                      final obs = observacoes[index];

                      if (_termoBusca.isNotEmpty &&
                          !(obs.nome.toLowerCase().contains(_termoBusca) ||
                            obs.contato.toLowerCase().contains(_termoBusca) ||
                            obs.observacao.toLowerCase().contains(_termoBusca))) {
                        return const SizedBox.shrink();
                      }
                      if (_dataSelecionada != null &&
                          !mesmaData(obs.dataHora, _dataSelecionada!)) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Data/Hora: ${formatarDataHora(obs.dataHora)}'),
                              const SizedBox(height: 8),
                              Text('Nome: ${obs.nome}'),
                              Text('Contato: ${obs.contato}'),
                              Text('Observação: ${obs.observacao}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  Future<void> _exportarVisitasCSV() async {
    final visitas = VisitaStorage.visitas.where((visita) {
      final matchBusca = _termoBusca.isEmpty || visita.endereco.toLowerCase().contains(_termoBusca);
      final matchData = _dataSelecionada == null || mesmaData(visita.dataHora, _dataSelecionada!);
      return matchBusca && matchData;
    }).toList();

    if (visitas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma visita encontrada para exportar.')),
      );
      return;
    }

    final csv = StringBuffer();
    csv.writeln('Data/Hora,Latitude,Longitude,Endereço');
    for (var visita in visitas) {
      csv.writeln('"${formatarDataHora(visita.dataHora)}",${visita.latitude},${visita.longitude},"${visita.endereco}"');
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/visitas_exportadas.csv';
    final file = File(path);
    await file.writeAsString(csv.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Arquivo exportado em:\n$path')),
    );
  }

  Future<void> _exportarObservacoesCSV() async {
    final observacoes = VisitaStorage.observacoes.where((obs) {
      final matchBusca = _termoBusca.isEmpty ||
          obs.nome.toLowerCase().contains(_termoBusca) ||
          obs.contato.toLowerCase().contains(_termoBusca) ||
          obs.observacao.toLowerCase().contains(_termoBusca);
      final matchData = _dataSelecionada == null || mesmaData(obs.dataHora, _dataSelecionada!);
      return matchBusca && matchData;
    }).toList();

    if (observacoes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma observação encontrada para exportar.')),
      );
      return;
    }

    final csv = StringBuffer();
    csv.writeln('Data/Hora,Nome,Contato,Observação');
    for (var obs in observacoes) {
      csv.writeln('"${formatarDataHora(obs.dataHora)}","${obs.nome}","${obs.contato}","${obs.observacao}"');
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/observacoes_exportadas.csv';
    final file = File(path);
    await file.writeAsString(csv.toString());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Arquivo exportado em:\n$path')),
    );
  }
}
