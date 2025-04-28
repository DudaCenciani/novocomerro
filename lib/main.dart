import 'package:flutter/material.dart';
import 'login_page.dart'; // Tela de login
import 'visita_storage.dart'; // Importar o VisitaStorage

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necessário para usar async no main
  await VisitaStorage.carregarDados(); // Carregar visitas e observações salvas
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
      home: const LoginPage(), // Tela inicial de login
    );
  }
}

