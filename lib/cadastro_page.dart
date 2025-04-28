import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  String? _errorMessage;

  // Função para salvar o novo usuário
  Future<void> _cadastrarUsuario() async {
    final usuario = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();

    if (usuario.isNotEmpty && senha.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario', usuario);
      await prefs.setString('senha', senha);

      // Após salvar, redireciona para a tela de login
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usuarioController,
              decoration: const InputDecoration(labelText: 'Usuário'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cadastrarUsuario,
              child: const Text('Cadastrar'),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
