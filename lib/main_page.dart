import 'package:flutter/material.dart';
import 'historico_page.dart'; // Tela para exibir o histórico do usuário comum
import 'admin_page.dart'; // Tela para exibir o histórico de todos os usuários
import 'realizar_visita_page.dart'; // Tela para realizar a visita
import 'fazer_observacao_page.dart'; // Tela para fazer observação

class MainPage extends StatelessWidget {
  final bool isAdmin;

  // Recebe o parâmetro isAdmin
  const MainPage({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tela Principal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Realizar visita
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RealizarVisitaPage()),
                );
              },
              child: const Text('Realizar Visita'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Fazer observação
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FazerObservacaoPage()),
                );
              },
              child: const Text('Fazer Observação'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Ver histórico (de acordo com o tipo de usuário)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => isAdmin ? const AdminPage() : const HistoricoPage(),
                  ),
                );
              },
              child: const Text('Ver Histórico'),
            ),
          ],
        ),
      ),
    );
  }
}
