import 'dart:convert';
import 'dart:typed_data';

class Visita {
  final String agenteSaude;
  final String nomePaciente;
  final String endereco;
  final double latitude;
  final double longitude;
  final DateTime dataHora;
  final String assinaturaBase64;
  final String? fotoBase64;
  bool sincronizada;

  Visita({
    required this.agenteSaude,
    required this.nomePaciente,
    required this.endereco,
    required this.latitude,
    required this.longitude,
    required this.dataHora,
    required this.assinaturaBase64,
    this.fotoBase64,
    this.sincronizada = false,
  });

  Map<String, dynamic> toMap() {
    final fotoValida = fotoBase64 != null && fotoBase64!.length < 1048487;

    return {
      'agenteSaude': agenteSaude,
      'nomePaciente': nomePaciente,
      'endereco': endereco,
      'latitude': latitude,
      'longitude': longitude,
      'dataHora': dataHora.toIso8601String(),
      'assinaturaBase64': assinaturaBase64,
      if (fotoValida) 'fotoBase64': fotoBase64,
      'sincronizada': sincronizada,
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
      assinaturaBase64: map['assinaturaBase64'],
      fotoBase64: map['fotoBase64'],
      sincronizada: map['sincronizada'] ?? false,
    );
  }

  Uint8List get assinatura => base64Decode(assinaturaBase64);

  Uint8List? get foto => fotoBase64 != null ? base64Decode(fotoBase64!) : null;
}
