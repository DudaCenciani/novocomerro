import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_page.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _codigoController = TextEditingController();

  String? _errorMessage;
  String? _verificacaoId;
  bool _codigoEnviado = false;
  bool _carregando = false;

  Future<void> _enviarCodigoSMS() async {
    final telefone = _telefoneController.text.trim();

    if (telefone.isEmpty || !telefone.startsWith('+')) {
      setState(() => _errorMessage = 'Inclua o número com DDI (ex: +55...)');
      return;
    }

    setState(() {
      _carregando = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: telefone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential cred) async {
          await FirebaseAuth.instance.signInWithCredential(cred);
          await _salvarLocalmente();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _errorMessage = 'Erro ao enviar código: ${e.message}';
            _carregando = false;
          });
        },
        codeSent: (String verificacaoId, int? resendToken) {
          setState(() {
            _verificacaoId = verificacaoId;
            _codigoEnviado = true;
            _carregando = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificacaoId) {
          _verificacaoId = verificacaoId;
        },
        
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro inesperado: $e';
        _carregando = false;
      });
    }
  }

  Future<void> _verificarCodigoESalvar() async {
    final codigo = _codigoController.text.trim();
    final usuario = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();

    if (usuario.isEmpty || senha.isEmpty || codigo.isEmpty || _verificacaoId == null) {
      setState(() => _errorMessage = 'Preencha todos os campos!');
      return;
    }

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificacaoId!,
        smsCode: codigo,
      );

      await FirebaseAuth.instance.signInWithCredential(cred);
      await _salvarLocalmente();
    } catch (e) {
      setState(() => _errorMessage = 'Código inválido ou expirado.');
    }
  }

  Future<void> _salvarLocalmente() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario', _usuarioController.text.trim());
    await prefs.setString('senha', _senhaController.text.trim());

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage(isAdmin: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro com Verificação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _usuarioController,
              decoration: const InputDecoration(labelText: 'Nome de usuário'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefoneController,
              decoration: const InputDecoration(labelText: 'Celular com DDI (ex: +55...)'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            if (_codigoEnviado)
              TextField(
                controller: _codigoController,
                decoration: const InputDecoration(labelText: 'Código SMS'),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _carregando
                  ? null
                  : _codigoEnviado
                      ? _verificarCodigoESalvar
                      : _enviarCodigoSMS,
              child: _carregando
                  ? const CircularProgressIndicator()
                  : Text(_codigoEnviado ? 'Verificar e Cadastrar' : 'Enviar Código'),
            ),
            if (_codigoEnviado)
              TextButton(
                onPressed: _enviarCodigoSMS,
                child: const Text('Reenviar código'),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
