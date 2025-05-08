import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'login_page.dart';
import 'visita_storage.dart'; // Para carregar dados locais

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();

    // ⚠️ Temporariamente troque para debug para gerar o token
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
 // ALTERADO TEMPORARIAMENTE
      webProvider: ReCaptchaV3Provider(''), // não usamos Web
    );

    // ✅ Gera o token de depuração e exibe no console
  

  } catch (e) {
    debugPrint('⚠️ Firebase não pôde ser inicializado: $e');
    // Continua normalmente com suporte apenas offline
  }

  await VisitaStorage.carregarDados();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Visita',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
