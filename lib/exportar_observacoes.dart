import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'visita_storage.dart';

Future<String> exportarObservacoesParaCSV(List<Observacao> observacoes) async {
  List<List<String>> dados = [
    ['Nome do Agente', 'Meio de Contato', 'Observação', 'Data e Hora'],
  ];

  for (var obs in observacoes) {
    dados.add([
      obs.nome,
      obs.contato,
      obs.observacao,
      obs.dataHora.toString(),
    ]);
  }

  String csvData = const ListToCsvConverter().convert(dados);

  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/observacoes.csv';
  final file = File(path);

  // ✅ Codificação UTF-8 com BOM
  await file.writeAsBytes(
    [0xEF, 0xBB, 0xBF] + utf8.encode(csvData),
  );

  return path;
}

Future<void> abrirArquivoObservacoesCSV(String caminho) async {
  await OpenFile.open(caminho);
}
