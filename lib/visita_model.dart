import 'dart:typed_data';
import 'dart:convert'; // Importante para base64Encode e base64Decode

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

  // Para salvar como JSON
  Map<String, dynamic> toJson() => {
        'assinatura': base64Encode(assinatura),
        'latitude': latitude,
        'longitude': longitude,
        'endereco': endereco,
        'dataHora': dataHora.toIso8601String(),
        'foto': foto != null ? base64Encode(foto!) : null,
      };

  // Para ler do JSON
  factory Visita.fromJson(Map<String, dynamic> json) => Visita(
        assinatura: base64Decode(json['assinatura']),
        latitude: json['latitude'],
        longitude: json['longitude'],
        endereco: json['endereco'],
        dataHora: DateTime.parse(json['dataHora']),
        foto: json['foto'] != null ? base64Decode(json['foto']) : null,
      );
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

  // Para salvar como JSON
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'contato': contato,
        'observacao': observacao,
        'dataHora': dataHora.toIso8601String(),
      };

  // Para ler do JSON
  factory Observacao.fromJson(Map<String, dynamic> json) => Observacao(
        nome: json['nome'],
        contato: json['contato'],
        observacao: json['observacao'],
        dataHora: DateTime.parse(json['dataHora']),
      );
}
