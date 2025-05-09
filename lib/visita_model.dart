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
    final fotoValida = fotoBase64 != null && fotoBase64!.isNotEmpty && fotoBase64!.length < 1048487;

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
    if (map['agenteSaude'] == null ||
        map['nomePaciente'] == null ||
        map['endereco'] == null ||
        map['latitude'] == null ||
        map['longitude'] == null ||
        map['dataHora'] == null ||
        map['assinaturaBase64'] == null) {
      throw ArgumentError('Campos obrigatórios ausentes no map da Visita');
    }

    return Visita(
      agenteSaude: map['agenteSaude'] as String,
      nomePaciente: map['nomePaciente'] as String,
      endereco: map['endereco'] as String,
      latitude: map['latitude'].toDouble(),
      longitude: map['longitude'].toDouble(),
      dataHora: DateTime.parse(map['dataHora']),
      assinaturaBase64: map['assinaturaBase64'] as String,
      fotoBase64: map['fotoBase64'] as String?,
      sincronizada: map['sincronizada'] ?? false,
    );
  }

  Uint8List get assinatura {
    try {
      return base64Decode(assinaturaBase64);
    } catch (_) {
      return Uint8List(0);
    }
  }

  Uint8List? get foto {
    if (fotoBase64 == null || fotoBase64!.isEmpty) return null;
    try {
      return base64Decode(fotoBase64!);
    } catch (_) {
      return null;
    }
  }
}
