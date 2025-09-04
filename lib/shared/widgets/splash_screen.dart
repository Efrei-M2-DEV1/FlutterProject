import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';

/// Écran de démarrage de l'application
///
/// Cet écran s'affiche pendant le chargement initial et redirige ensuite
/// vers l'écran approprié (login si pas connecté, tâches si connecté)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Contrôleur d'animation pour l'effet de fondu
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation de fondu
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this, // this = _SplashScreenState qui implémente TickerProvider
    );

    _fadeAnimation =
        Tween<double>(
          begin: 0.0, // Transparent au début
          end: 1.0, // Opaque à la fin
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeIn, // Animation progressive
          ),
        );

    // Démarrer l'animation et la navigation
    _startSplashSequence();
  }

  /// Séquence de démarrage : animation + redirection
  Future<void> _startSplashSequence() async {
    // Démarrer l'animation
    _animationController.forward();

    // Attendre 3 secondes
    await Future.delayed(const Duration(seconds: 3));

    // Vérifier si le widget est encore monté (bonne pratique)
    if (!mounted) return;

    // TODO: Le Lead Auth ajoutera ici la vérification de session
    // if (authProvider.isLoggedIn) {
    //   context.goToTasks();
    // } else {
    //   context.goToLogin();
    // }

    // Pour l'instant, toujours aller au login
    context.goToLogin();
  }

  @override
  void dispose() {
    // IMPORTANT : libérer les ressources pour éviter les fuites mémoire
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient de fond pour un effet moderne
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo de l'app (icône temporaire)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nom de l'app
                    const Text(
                      'Todo List Pro',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Slogan
                    const Text(
                      'Organisez votre quotidien',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),

                    const SizedBox(height: 40),

                    // Indicateur de chargement
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
