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
  final _nomeController = TextEditingController(); // Novo campo para nome
  String? _errorMessage;

  // Função para verificar o login
  Future<void> _login() async {
    final usuario = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();
    final nomePaciente = _nomeController.text.trim(); // Obtendo nome

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuarioSalvo = prefs.getString('usuario');
    String? senhaSalva = prefs.getString('senha');

    // Verificando se o login está correto
    // Login como usuário comum
if (usuario == usuarioSalvo && senha == senhaSalva) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MainPage(isAdmin: false)),
  );
}
// Login como administrador
else if (usuario == 'admin' && senha == 'admin123') {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const MainPage(isAdmin: true)),
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
        backgroundColor: Colors.blueAccent, // Mudando a cor da AppBar
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
            // Novo campo para o nome do paciente
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Paciente',
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
 // Mudando a cor do botão
                textStyle: const TextStyle(fontSize: 20),
              ),
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
              child: const Text(
                'Não tem uma conta? Cadastre-se',
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
