import 'package:flutter/material.dart';
import 'visita_storage.dart';

class FazerObservacaoPage extends StatefulWidget {
  const FazerObservacaoPage({super.key});

  @override
  State<FazerObservacaoPage> createState() => _FazerObservacaoPageState();
}

class _FazerObservacaoPageState extends State<FazerObservacaoPage> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController contatoController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();

  Future<void> _salvarObservacao() async {
    if (nomeController.text.isEmpty || observacaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha o nome e a observação.')),
      );
      return;
    }

    final observacao = Observacao(
      nome: nomeController.text,
      contato: contatoController.text,
      observacao: observacaoController.text,
      dataHora: DateTime.now(),
    );

    await VisitaStorage.salvarObservacao(observacao);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Observação salva com sucesso!')),
    );

    // Limpa os campos
    nomeController.clear();
    contatoController.clear();
    observacaoController.clear();
  }

  @override
  void dispose() {
    nomeController.dispose();
    contatoController.dispose();
    observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fazer Observação')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contatoController,
              decoration: const InputDecoration(labelText: 'Meio de Contato'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: observacaoController,
              decoration: const InputDecoration(labelText: 'Observação'),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
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
