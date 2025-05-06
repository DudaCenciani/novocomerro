// ✅ lib/realizar_visita_page.dart
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'visita_model.dart';
import 'visita_storage.dart';
import 'visualizar_visita_page.dart';

class RealizarVisitaPage extends StatefulWidget {
  const RealizarVisitaPage({super.key});

  @override
  State<RealizarVisitaPage> createState() => _RealizarVisitaPageState();
}

class _RealizarVisitaPageState extends State<RealizarVisitaPage> {
  final SignatureController _signatureController = SignatureController(penStrokeWidth: 3, penColor: Colors.black);
  final TextEditingController _nomePacienteController = TextEditingController();
  Uint8List? _foto;
  bool _salvando = false;

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _foto = bytes;
      });
    }
  }

  Future<void> _salvarVisita() async {
    if (_nomePacienteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe o nome do paciente.')),
      );
      return;
    }

    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, colete a assinatura.')),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço de localização desativado.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissão de localização negada.')),
          );
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final endereco = "${placemarks.first.street}, ${placemarks.first.subLocality}, ${placemarks.first.locality}";

      await Future.delayed(const Duration(milliseconds: 100));
      _signatureController.notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));

      final image = await _signatureController.toImage();
if (image == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Falha ao capturar a assinatura (imagem nula).')),
  );
  setState(() {
    _salvando = false;
  });
  return;
}

final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
final assinaturaBytes = byteData?.buffer.asUint8List();

if (assinaturaBytes == null || assinaturaBytes.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Falha ao gerar os bytes da assinatura.')),
  );
  setState(() {
    _salvando = false;
  });
  return;
}

      
      print('🖋️ Assinatura bytes length: ${assinaturaBytes?.length}');

      if (assinaturaBytes == null || assinaturaBytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao capturar a assinatura.')),
        );
        setState(() {
          _salvando = false;
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final agenteSaude = prefs.getString('usuario') ?? 'Agente Desconhecido';

      final novaVisita = Visita(
  agenteSaude: agenteSaude,
  nomePaciente: _nomePacienteController.text,
  endereco: endereco,
  latitude: position.latitude,
  longitude: position.longitude,
  dataHora: DateTime.now(),
  assinaturaBase64: base64Encode(assinaturaBytes),
  fotoBase64: _foto != null ? base64Encode(_foto!) : null,
);

await VisitaStorage.salvarVisita(novaVisita);

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VisualizarVisitaPage(visita: novaVisita),
  ),
);

    } finally {
      setState(() {
        _salvando = false;
      });
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _nomePacienteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Visita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nomePacienteController,
              decoration: const InputDecoration(
                labelText: 'Nome do Paciente',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Assinatura:'),
            Container(
              decoration: BoxDecoration(border: Border.all()),
              height: 150,
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _signatureController.clear(),
                  child: const Text('Limpar'),
                ),
                ElevatedButton(
                  onPressed: _tirarFoto,
                  child: const Text('Tirar Foto (opcional)'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _foto != null
                ? Image.memory(_foto!, height: 150)
                : const Text('Nenhuma foto tirada.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _salvando ? null : _salvarVisita,
              child: _salvando
                  ? const CircularProgressIndicator()
                  : const Text('Salvar Visita'),
            ),
          ],
        ),
      ),
    );
  }
}

