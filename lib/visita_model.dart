// lib/visita_model.dart
import 'dart:typed_data';
import 'dart:convert';

class Visita {
  final String agenteSaude;
  final String nomePaciente;
  final String endereco;
  final double latitude;
  final double longitude;
  final DateTime dataHora;
  final Uint8List assinatura;
  final Uint8List? foto;

  Visita({
    required this.agenteSaude,
    required this.nomePaciente,
    required this.endereco,
    required this.latitude,
    required this.longitude,
    required this.dataHora,
    required this.assinatura,
    this.foto,
  });

  Map<String, dynamic> toMap() {
    return {
      'agenteSaude': agenteSaude,
      'nomePaciente': nomePaciente,
      'endereco': endereco,
      'latitude': latitude,
      'longitude': longitude,
      'dataHora': dataHora.toIso8601String(),
      'assinatura': base64Encode(assinatura),
      'foto': foto != null ? base64Encode(foto!) : null,
    };
  }

  factory Visita.fromMap(Map<String, dynamic> map) {
    return Visita(
      agenteSaude: map['agenteSaude'],
      nomePaciente: map['nomePaciente'],
      endereco: map['endereco'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      dataHora: DateTime.parse(map['dataHora']),
      assinatura: base64Decode(map['assinatura']),
      foto: map['foto'] != null ? base64Decode(map['foto']) : null,
    );
  }
}