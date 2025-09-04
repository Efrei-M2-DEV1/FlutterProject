import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

/// Point d'entrée principal de l'application
///
/// Cette fonction main() est appelée au démarrage de l'app.
/// Elle configure l'environnement Flutter avant de lancer l'interface
void main() async {
  // ===== INITIALISATION FLUTTER =====
  // OBLIGATOIRE quand on fait des opérations async avant runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // ===== CONFIGURATION DE L'INTERFACE SYSTÈME =====
  // Configure la barre de statut et la navigation (Android/iOS)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // Barre de statut transparente avec icônes sombres
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,

      // Barre de navigation système (Android)
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // ===== ORIENTATION DE L'ÉCRAN =====
  // Force l'orientation portrait pour une meilleure UX mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Portrait normal
    DeviceOrientation.portraitDown, // Portrait inversé
  ]);

  // TODO: Le Lead Auth initialisera Firebase ici
  // await Firebase.initializeApp();

  // ===== LANCEMENT DE L'APPLICATION =====
  runApp(const TodoApp());
}
