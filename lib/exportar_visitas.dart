import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'visita_model.dart';

Future<String> exportarVisitasParaCSV(List<Visita> visitasParaExportar) async {
  List<List<String>> dados = [
    ['Nome do Agente', 'Nome do Paciente', 'Latitude', 'Longitude', 'Endereço', 'Data e Hora'],
  ];

  for (var visita in visitasParaExportar) {
    dados.add([
      visita.agenteSaude,
      visita.nomePaciente,
      visita.latitude.toString(),
      visita.longitude.toString(),
      visita.endereco,
      DateFormat('dd/MM/yyyy HH:mm').format(visita.dataHora),
    ]);
  }

  String csvData = const ListToCsvConverter().convert(dados);

  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/historico_visitas.csv';
  final File file = File(path);

  // ✅ Codificação UTF-8 com BOM para compatibilidade com Google Sheets
  await file.writeAsBytes(
    [0xEF, 0xBB, 0xBF] + utf8.encode(csvData),
  );

  return path;
}

Future<void> abrirArquivoCSV(String caminhoArquivo) async {
  final resultado = await OpenFile.open(caminhoArquivo);
  print('Resultado ao abrir: ${resultado.message}');
}
