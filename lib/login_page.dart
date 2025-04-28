import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart'; // Tela principal após login
import 'cadastro_page.dart'; // Tela para o cadastro de novos usuários

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  String? _errorMessage;

  // Função para verificar o login
  Future<void> _login() async {
    final usuario = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuarioSalvo = prefs.getString('usuario');
    String? senhaSalva = prefs.getString('senha');

    // Verificando se o login está correto
    if (usuario == usuarioSalvo && senha == senhaSalva) {
      // Redirecionar para a tela principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage(isAdmin: false)),
      );
    } else if (usuario == 'admin' && senha == 'admin123') {
      // Usuário admin com login fixo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage(isAdmin: true)),
      );
    } else {
      setState(() {
        _errorMessage = 'Usuário ou senha inválidos!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
              onPressed: _login,
              child: const Text('Entrar'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Redireciona para a tela de cadastro
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CadastroPage()),
                );
              },
              child: const Text('Não tem uma conta? Cadastre-se'),
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
