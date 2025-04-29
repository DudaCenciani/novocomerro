import 'package:flutter/material.dart';
import 'login_page.dart'; // Tela de login
import 'visita_storage.dart'; // Classe que carrega visitas e observações



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   // Necessário para usar 'await' antes de runApp
  await VisitaStorage.carregarDados();       // Agora seguro com tratamento de erros
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
      home: const LoginPage(), // Tela inicial do app
      debugShowCheckedModeBanner: false,
    );
  }
}
