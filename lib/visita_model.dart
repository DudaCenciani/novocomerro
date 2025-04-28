import 'dart:typed_data';

class Visita {
  final Uint8List assinatura;
  final double latitude;
  final double longitude;
  final String endereco;
  final DateTime dataHora;
  final Uint8List? foto;

  Visita({
    required this.assinatura,
    required this.latitude,
    required this.longitude,
    required this.endereco,
    required this.dataHora,
    this.foto,
  });
}

class Observacao {
  final String nome;
  final String contato;
  final String observacao;
  final DateTime dataHora;

  Observacao({
    required this.nome,
    required this.contato,
    required this.observacao,
    required this.dataHora,
  });
}
