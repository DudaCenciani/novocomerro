import 'package:flutter/material.dart';
import 'historico_page.dart';
import 'admin_page.dart';
import 'realizar_visita_page.dart';
import 'fazer_observacao_page.dart';
import 'visita_storage.dart'; // necessário para limpar os dados

class MainPage extends StatelessWidget {
  final bool isAdmin;

  const MainPage({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isAdmin ? 'Menu do Administrador' : 'Menu Principal'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RealizarVisitaPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    textStyle: const TextStyle(fontSize: 22),
                  ),
                  child: const Text('Realizar Visita'),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FazerObservacaoPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    textStyle: const TextStyle(fontSize: 22),
                  ),
                  child: const Text('Fazer Observação'),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => isAdmin ? const AdminPage() : const HistoricoPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    textStyle: const TextStyle(fontSize: 22),
                  ),
                  child: const Text('Ver Histórico'),
                ),
              ),
              const SizedBox(height: 30),
              // 🔧 Botão temporário para limpar todos os dados
              
            ],
          ),
        ),
      ),
    );
  }
}
