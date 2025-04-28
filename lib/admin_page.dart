import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Todos os Usuários'),
      ),
      body: Center(
        child: const Text(
          'Aqui o administrador verá o histórico de todas as visitas de todos os usuários.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
