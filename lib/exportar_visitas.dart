import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:open_file/open_file.dart';
import 'visita_model.dart';

Future<String> exportarVisitasParaCSV(List<Visita> visitasParaExportar) async {
  List<List<String>> dados = [
    ['Data/Hora', 'Paciente', 'Latitude', 'Longitude', 'Endereço'],
  ];

  for (var visita in visitasParaExportar) {
    dados.add([
      visita.dataHora.toString(),
      visita.nomePaciente,
      visita.latitude.toString(),
      visita.longitude.toString(),
      visita.endereco,
    ]);
  }

  String csvData = const ListToCsvConverter().convert(dados);

  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/historico_visitas.csv';
  final File file = File(path);

  await file.writeAsString(csvData);

  return path;
}

Future<void> abrirArquivoCSV(String caminhoArquivo) async {
  final resultado = await OpenFile.open(caminhoArquivo);
  print('Resultado ao abrir: ${resultado.message}');
}

