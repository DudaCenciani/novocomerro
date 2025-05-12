import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';
import 'cadastro_page.dart';
import 'esqueci_senha_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  String? _errorMessage;

  Future<void> _login() async {
    final usuario = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final usuarioSalvo = prefs.getString('usuario');
    final senhaSalva = prefs.getString('senha');
    final roleSalvo = prefs.getString('role') ?? 'agente';

    if (usuario == usuarioSalvo && senha == senhaSalva) {
      final isAdmin = roleSalvo == 'admin';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage(isAdmin: isAdmin)),
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
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usuarioController,
              decoration: const InputDecoration(
                labelText: 'Usuário',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Entrar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CadastroPage()),
                );
              },
              child: const Text(
                'Não tem uma conta? Cadastre-se',
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EsqueciSenhaPage()),
                );
              },
              child: const Text(
                'Esqueci minha senha',
                style: TextStyle(fontSize: 16),
              ),
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
