import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'visualizar_visita_page.dart';

class RealizarVisitaPage extends StatefulWidget {
  const RealizarVisitaPage({super.key});

  @override
  State<RealizarVisitaPage> createState() => _RealizarVisitaPageState();
}

class _RealizarVisitaPageState extends State<RealizarVisitaPage> {
  final SignatureController _signatureController = SignatureController(penStrokeWidth: 3, penColor: Colors.black);
  Uint8List? _foto;

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
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, assine antes de salvar.')),
      );
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localização não está ativada.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada.')),
        );
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks.first;
    String enderecoCompleto = '${place.street}, ${place.subLocality}, ${place.locality} - ${place.administrativeArea}';

    final assinaturaBytes = await _signatureController.toPngBytes();
    if (assinaturaBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao capturar assinatura.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisualizarVisitaPage(
          assinatura: assinaturaBytes,
          dataHora: DateTime.now(),
          endereco: enderecoCompleto,
          foto: _foto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Azul claro
      appBar: AppBar(
        title: const Text('Realizar Visita'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Assinatura:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              height: 300, // Área de assinatura maior
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => _signatureController.clear(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Limpar Assinatura'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _tirarFoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Tirar Foto (opcional)'),
              ),
            ),
            const SizedBox(height: 20),
            if (_foto != null)
              Image.memory(
                _foto!,
                height: 200,
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _salvarVisita,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  textStyle: const TextStyle(fontSize: 22),
                ),
                child: const Text('Salvar Visita'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

