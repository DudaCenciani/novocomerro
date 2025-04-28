import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'visita_storage.dart'; // Atualizado para usar VisitaStorage
import 'visita_model.dart';   // Importa o modelo certo

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

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: TabBarView(
                children: [
                  // Aba de Visitas
                  _buildVisitasList(),
                  // Aba de Observações
                  _buildObservacoesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitasList() {
    final visitas = VisitaStorage.visitas;

    final visitasFiltradas = visitas.where((visita) {
      final matchBusca = _termoBusca.isEmpty || visita.endereco.toLowerCase().contains(_termoBusca);
      final matchData = _dataSelecionada == null || mesmaData(visita.dataHora, _dataSelecionada!);
      return matchBusca && matchData;
    }).toList();

    if (visitasFiltradas.isEmpty) {
      return const Center(child: Text('Nenhuma visita registrada.'));
    }

    return ListView.builder(
      itemCount: visitasFiltradas.length,
      itemBuilder: (context, index) {
        final visita = visitasFiltradas[index];

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
    );
  }

  Widget _buildObservacoesList() {
    final observacoes = VisitaStorage.observacoes;

    final observacoesFiltradas = observacoes.where((obs) {
      final matchBusca = _termoBusca.isEmpty ||
          obs.nome.toLowerCase().contains(_termoBusca) ||
          obs.contato.toLowerCase().contains(_termoBusca) ||
          obs.observacao.toLowerCase().contains(_termoBusca);
      final matchData = _dataSelecionada == null || mesmaData(obs.dataHora, _dataSelecionada!);
      return matchBusca && matchData;
    }).toList();

    if (observacoesFiltradas.isEmpty) {
      return const Center(child: Text('Nenhuma observação registrada.'));
    }

    return ListView.builder(
      itemCount: observacoesFiltradas.length,
      itemBuilder: (context, index) {
        final obs = observacoesFiltradas[index];

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
    );
  }
}
