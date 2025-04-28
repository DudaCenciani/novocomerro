import 'package:flutter/material.dart';

import 'visita_model.dart';
import 'visita_storage.dart';

class FazerObservacaoPage extends StatefulWidget {
  const FazerObservacaoPage({super.key});

  @override
  State<FazerObservacaoPage> createState() => _FazerObservacaoPageState();
}

class _FazerObservacaoPageState extends State<FazerObservacaoPage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _contatoController = TextEditingController();
  final TextEditingController _observacaoController = TextEditingController();

  void _salvarObservacao() {
    String nome = _nomeController.text.trim();
    String contato = _contatoController.text.trim();
    String observacaoTexto = _observacaoController.text.trim();

    if (nome.isEmpty || contato.isEmpty || observacaoTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    final observacao = Observacao(
      nome: nome,
      contato: contato,
      observacao: observacaoTexto,
      dataHora: DateTime.now(),
    );

    VisitaStorage.adicionarObservacao(observacao);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Observação salva com sucesso!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fazer Observação'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contatoController,
              decoration: const InputDecoration(labelText: 'Meio de Contato'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _observacaoController,
              decoration: const InputDecoration(labelText: 'Observação'),
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvarObservacao,
              child: const Text('Salvar Observação'),
            ),
          ],
        ),
      ),
    );
  }
}
