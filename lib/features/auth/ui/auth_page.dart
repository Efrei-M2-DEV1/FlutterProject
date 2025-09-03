import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // TODO: implémenter login; pour l’instant on va sur /tasks
            context.go('/tasks');
          },
          child: const Text('Se connecter (mock)'),
        ),
      ),
    );
  }
}
