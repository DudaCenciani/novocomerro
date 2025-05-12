import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'visita_model.dart';
import 'visita_storage.dart';
import 'visualizar_visita_page.dart';

class RealizarVisitaPage extends StatefulWidget {
  const RealizarVisitaPage({super.key});

  @override
  State<RealizarVisitaPage> createState() => _RealizarVisitaPageState();
}

class _RealizarVisitaPageState extends State<RealizarVisitaPage> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );
  final TextEditingController _nomePacienteController = TextEditingController();
  Uint8List? _foto;
  bool _salvando = false;

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final originalBytes = await pickedFile.readAsBytes();

      final compressedBytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: 800,
        minHeight: 800,
        quality: 60,
        format: CompressFormat.jpeg,
      );

      setState(() {
        _foto = Uint8List.fromList(compressedBytes);
      });

      print('📷 Foto capturada e comprimida. Tamanho final: ${_foto!.lengthInBytes} bytes');
    }
  }

  Future<void> _salvarVisita() async {
    print('🔹 Início do _salvarVisita');

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
      print('🔹 Verificando localização...');
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

      print('🔹 Obtendo posição GPS com alta precisão...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('🔹 Tentando obter endereço (pode falhar offline)...');
      String endereco = 'Endereço não disponível';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          endereco = "${place.street}, ${place.subLocality}, ${place.locality}";
        }
      } catch (e) {
        print('⚠️ Falha ao obter endereço: $e');
      }

      await Future.delayed(const Duration(milliseconds: 100));
      _signatureController.notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));

      print('🔹 Capturando assinatura...');
      final image = await _signatureController.toImage();
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao capturar a assinatura.')),
        );
        setState(() => _salvando = false);
        return;
      }

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final assinaturaBytes = byteData?.buffer.asUint8List();

      if (assinaturaBytes == null || assinaturaBytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao processar a assinatura.')),
        );
        setState(() => _salvando = false);
        return;
      }

      print('🔹 Recuperando nome do agente de saúde...');
      final prefs = await SharedPreferences.getInstance();
      final agente = prefs.getString('usuario');

      if (agente == null || agente.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado. Faça login novamente.')),
        );
        setState(() => _salvando = false);
        return;
      }

      print('🔹 Criando objeto Visita...');
      final novaVisita = Visita(
        agenteSaude: agente,
        nomePaciente: _nomePacienteController.text,
        endereco: endereco,
        latitude: position.latitude,
        longitude: position.longitude,
        dataHora: DateTime.now(),
        assinaturaBase64: base64Encode(assinaturaBytes),
        fotoBase64: _foto != null ? base64Encode(_foto!) : null,
        sincronizada: false,
      );

      print('🔹 Salvando localmente...');
      await VisitaStorage.salvarVisita(novaVisita);

      print('✅ Visita salva com sucesso!');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VisualizarVisitaPage(visita: novaVisita),
        ),
      );
    } catch (e) {
      print('❌ Erro ao salvar visita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar visita: $e')),
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
      appBar: AppBar(title: const Text('Realizar Visita')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _nomePacienteController,
              decoration: const InputDecoration(labelText: 'Nome do Paciente'),
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
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
