import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'visita_storage.dart';
import 'visita_model.dart';
import 'detalhes_visita_page.dart';
import 'login_page.dart';
import 'exportar_visitas.dart';
import 'exportar_observacoes.dart';
import 'sincronizacao_service.dart';
import 'sincronizacao_observacoes.dart';

class HistoricoPage extends StatefulWidget {
  const HistoricoPage({super.key});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage>
    with SingleTickerProviderStateMixin {
  String _termoBusca = '';
  DateTime? _dataSelecionada;
  String _usuarioLogado = '';
  String _papelUsuario = 'agente';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarUsuario();
    _carregarDadosLocais();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usuarioLogado = prefs.getString('usuario') ?? '';
      _papelUsuario = prefs.getString('role') ?? 'agente';
    });
  }

  Future<void> _carregarDadosLocais() async {
    await VisitaStorage.carregarDados();
    setState(() {});
  }

  Future<void> _logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

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

  List<Visita> _filtrarVisitas() {
    final todasVisitas = VisitaStorage.visitas;

    return todasVisitas.where((visita) {
      final ehAdmin = _papelUsuario == 'admin';
      final pertenceAoUsuario = visita.agenteSaude.toLowerCase() == _usuarioLogado.toLowerCase();
      final podeVisualizar = ehAdmin || pertenceAoUsuario;

      final matchBusca = _termoBusca.isEmpty ||
          visita.endereco.toLowerCase().contains(_termoBusca) ||
          visita.nomePaciente.toLowerCase().contains(_termoBusca) ||
          visita.agenteSaude.toLowerCase().contains(_termoBusca);
      final matchData = _dataSelecionada == null || mesmaData(visita.dataHora, _dataSelecionada!);

      return podeVisualizar && matchBusca && matchData;
    }).toList();
  }

  List<Observacao> _filtrarObservacoes() {
    final todas = VisitaStorage.observacoes;
    final isAdmin = _papelUsuario == 'admin';

    return todas.where((obs) {
      final pertenceAoUsuario = isAdmin || obs.nome.toLowerCase() == _usuarioLogado.toLowerCase();
      final matchBusca = _termoBusca.isEmpty ||
          obs.nome.toLowerCase().contains(_termoBusca) ||
          obs.contato.toLowerCase().contains(_termoBusca) ||
          obs.observacao.toLowerCase().contains(_termoBusca);
      final matchData = _dataSelecionada == null || mesmaData(obs.dataHora, _dataSelecionada!);
      return pertenceAoUsuario && matchBusca && matchData;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Histórico'),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: 'Sincronizar Dados',
              onPressed: () async {
                await sincronizarVisitasOffline();
                await sincronizarObservacoesOffline();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dados sincronizados com sucesso.')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.file_download),
              tooltip: 'Exportar Histórico',
              onPressed: () async {
                final abaSelecionada = _tabController.index;
                if (abaSelecionada == 0) {
                  final visitasFiltradas = _filtrarVisitas();
                  final caminhoVisitas = await exportarVisitasParaCSV(visitasFiltradas);
                  await abrirArquivoCSV(caminhoVisitas);
                } else {
                  final observacoesFiltradas = _filtrarObservacoes();
                  final caminhoObs = await exportarObservacoesParaCSV(observacoesFiltradas);
                  await abrirArquivoObservacoesCSV(caminhoObs);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
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
                controller: _tabController,
                children: [
                  _buildVisitasList(),
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
    final visitasFiltradas = _filtrarVisitas();

    if (visitasFiltradas.isEmpty) {
      return const Center(child: Text('Nenhuma visita registrada.'));
    }

    return ListView.builder(
      itemCount: visitasFiltradas.length,
      itemBuilder: (context, index) {
        final visita = visitasFiltradas[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalhesVisitaPage(visita: visita),
              ),
            );
          },
          child: Card(
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
                  Text('Agente: ${visita.agenteSaude}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Paciente: ${visita.nomePaciente}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Data/Hora: ${formatarDataHora(visita.dataHora)}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Endereço: ${visita.endereco}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Latitude: ${visita.latitude}', style: const TextStyle(fontSize: 14)),
                  Text('Longitude: ${visita.longitude}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        children: [
                          const Text('Foto:'),
                          const SizedBox(height: 4),
                          visita.foto != null
                              ? Image.memory(visita.foto!, width: 80, height: 80, fit: BoxFit.cover)
                              : const Text('Sem foto'),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          const Text('Assinatura:'),
                          const SizedBox(height: 4),
                          visita.assinatura.isNotEmpty
                              ? Image.memory(visita.assinatura, width: 80, height: 80, fit: BoxFit.contain)
                              : const Text('Sem assinatura'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildObservacoesList() {
    final observacoesFiltradas = _filtrarObservacoes();

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
