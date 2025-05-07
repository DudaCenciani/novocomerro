import 'package:flutter/material.dart';
import 'historico_page.dart';
import 'admin_page.dart';
import 'realizar_visita_page.dart';
import 'fazer_observacao_page.dart';
import 'visita_storage.dart';
import 'sincronizacao_service.dart';
import 'sincronizacao_observacoes.dart';

class MainPage extends StatefulWidget {
  final bool isAdmin;

  const MainPage({super.key, required this.isAdmin});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _carregado = false;

  @override
  void initState() {
    super.initState();
    _carregarDadosLocais();
  }

  Future<void> _carregarDadosLocais() async {
    await VisitaStorage.carregarDados();
    setState(() {
      _carregado = true;
    });
  }

  Future<void> _sincronizarDados() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔄 Verificando dados para sincronizar...')),
    );

    await VisitaStorage.carregarDados();

    final visitasPendentes =
        VisitaStorage.visitas.where((v) => !v.sincronizada).toList();
    final observacoesPendentes =
        VisitaStorage.observacoes.where((o) => !o.sincronizada).toList();

    if (visitasPendentes.isEmpty && observacoesPendentes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Nenhum dado pendente para sincronizar.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🔁 Sincronizando dados...')),
    );

    await tentarSincronizarComInternet();
    await tentarSincronizarObservacoesComInternet();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Sincronização concluída.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_carregado) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'Menu do Administrador' : 'Menu Principal'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar agora',
            onPressed: _sincronizarDados,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBotao('Realizar Visita', const RealizarVisitaPage()),
              const SizedBox(height: 30),
              _buildBotao('Fazer Observação', const FazerObservacaoPage()),
              const SizedBox(height: 30),
              _buildBotao(
                'Ver Histórico',
                widget.isAdmin ? const AdminPage() : const HistoricoPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotao(String texto, Widget destino) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destino),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          textStyle: const TextStyle(fontSize: 22),
        ),
        child: Text(texto),
      ),
    );
  }
}
