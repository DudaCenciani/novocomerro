import 'dart:typed_data';

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
      'assinatura': assinatura,
      'foto': foto,
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
      assinatura: Uint8List.fromList(List<int>.from(map['assinatura'])),
      foto: map['foto'] != null
          ? Uint8List.fromList(List<int>.from(map['foto']))
          : null,
    );
  }
}
