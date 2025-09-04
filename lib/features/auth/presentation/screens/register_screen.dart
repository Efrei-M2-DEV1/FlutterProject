import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Écran d\'inscription'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.goToLogin(),
              child: const Text('Retour à la connexion'),
            ),
          ],
        ),
      ),
    );
  }
}
