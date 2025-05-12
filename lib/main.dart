import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'login_page.dart';
import 'cadastro_page.dart';
import 'esqueci_senha_page.dart';
import 'main_page.dart';
import 'visita_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();

    await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
);

  } catch (e) {
    debugPrint('⚠️ Firebase não pôde ser inicializado: $e');
  }

  await VisitaStorage.carregarDados();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bela Saúde',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/cadastro': (context) => const CadastroPage(),
        '/esqueci-senha': (context) => const EsqueciSenhaPage(),
        '/main': (context) => const MainPage(isAdmin: false), // usado apenas se necessário
      },
    );
  }
}
