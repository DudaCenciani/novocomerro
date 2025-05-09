import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EsqueciSenhaPage extends StatefulWidget {
  const EsqueciSenhaPage({super.key});

  @override
  State<EsqueciSenhaPage> createState() => _EsqueciSenhaPageState();
}

class _EsqueciSenhaPageState extends State<EsqueciSenhaPage> {
  final _usuarioController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _codigoController = TextEditingController();
  final _novaSenhaController = TextEditingController();

  String? _verificacaoId;
  bool _codigoEnviado = false;
  bool _carregando = false;
  String? _mensagemErro;

  Future<void> _enviarCodigo() async {
    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    final telefone = _telefoneController.text.trim();

    if (!telefone.startsWith('+')) {
      setState(() {
        _mensagemErro = 'Inclua o número com DDI (ex: +55...)';
        _carregando = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: telefone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          setState(() {
            _mensagemErro = 'Erro: ${e.message}';
            _carregando = false;
          });
        },
        codeSent: (id, _) {
          setState(() {
            _verificacaoId = id;
            _codigoEnviado = true;
            _carregando = false;
          });
        },
        codeAutoRetrievalTimeout: (id) {
          _verificacaoId = id;
        },
      );
    } catch (e) {
      setState(() {
        _mensagemErro = 'Erro inesperado: $e';
        _carregando = false;
      });
    }
  }

  Future<void> _verificarECadastrarNovaSenha() async {
    final usuario = _usuarioController.text.trim();
    final novaSenha = _novaSenhaController.text.trim();
    final codigo = _codigoController.text.trim();

    if (_verificacaoId == null || codigo.isEmpty || novaSenha.isEmpty || usuario.isEmpty) {
      setState(() => _mensagemErro = 'Preencha todos os campos!');
      return;
    }

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificacaoId!,
        smsCode: codigo,
      );

      await FirebaseAuth.instance.signInWithCredential(cred);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario', usuario);
      await prefs.setString('senha', novaSenha);

      if (!mounted) return;
      Navigator.pop(context); // volta para a tela de login

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso!')),
      );
    } catch (e) {
      setState(() => _mensagemErro = 'Código inválido ou expirado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Redefinir Senha'),
          backgroundColor: Colors.blueAccent,
        ),
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
                controller: _telefoneController,
                decoration: const InputDecoration(labelText: 'Celular com DDI (ex: +55...)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              if (_codigoEnviado)
                Column(
                  children: [
                    TextField(
                      controller: _codigoController,
                      decoration: const InputDecoration(labelText: 'Código SMS'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _novaSenhaController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Nova Senha'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _carregando
                    ? null
                    : _codigoEnviado
                        ? _verificarECadastrarNovaSenha
                        : _enviarCodigo,
                child: _carregando
                    ? const CircularProgressIndicator()
                    : Text(_codigoEnviado ? 'Salvar nova senha' : 'Enviar código'),
              ),
              if (_mensagemErro != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _mensagemErro!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
