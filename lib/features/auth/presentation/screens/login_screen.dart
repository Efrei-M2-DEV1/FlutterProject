import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../data/auth_service.dart';

/// Écran de connexion moderne et élégant
///
/// Fonctionnalités :
/// - Design moderne avec gradient
/// - Formulaire avec validation
/// - Animation et feedback utilisateur
/// - Navigation fluide
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Contrôleurs pour les champs de texte
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // États du formulaire
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Configuration des animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    // Démarrer l'animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Fonction de connexion (simulée pour l'instant)
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Utiliser le service d'authentification
    final authService = context.read<AuthService>();
    final result = await authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      // Navigation vers les tâches
      context.goToTasks();
    } else {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Erreur lors de la connexion'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Fonction pour gérer le mot de passe oublié
  Future<void> _handleForgotPassword() async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final emailToReset = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser le mot de passe'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: emailController,
                label: 'Email',
                hint: 'votre.email@exemple.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: _validateEmail,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(emailController.text);
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );

    if (emailToReset != null && mounted) {
      // Simuler l'envoi de l'email
      setState(() => _isLoading = true);

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Un email de réinitialisation a été envoyé à $emailToReset',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: AppTheme.paddingLarge,
      child: Column(
        children: [
          const SizedBox(height: 60),

          // ===== HEADER AVEC LOGO =====
          _buildHeader(),

          const SizedBox(height: 60),

          // ===== FORMULAIRE DE CONNEXION =====
          _buildLoginForm(),

          const SizedBox(height: 30),

          // ===== LIENS D'ACTIONS =====
          _buildActionLinks(),
        ],
      ),
    );
  }

  /// Header avec logo et titre
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo de l'app
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.checklist_rounded,
            size: 50,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 24),

        // Titre principal
        const Text(
          'Todo List Pro',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        // Sous-titre
        const Text(
          'Organisez votre vie, une tâche à la fois',
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Formulaire de connexion
  Widget _buildLoginForm() {
    return Container(
      padding: AppTheme.paddingLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre du formulaire
            Text(
              'Connexion',
              style: AppTextStyles.titleLarge(context),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Connectez-vous pour accéder à vos tâches',
              style: AppTextStyles.bodyMedium(context),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Champ email
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'votre.email@exemple.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: _validateEmail,
            ),

            const SizedBox(height: 16),

            // Champ mot de passe
            CustomTextField(
              controller: _passwordController,
              label: 'Mot de passe',
              hint: 'Votre mot de passe',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: _validatePassword,
            ),

            const SizedBox(height: 24),

            // Bouton de connexion
            CustomButton(
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }

  /// Liens d'actions (inscription, mot de passe oublié)
  Widget _buildActionLinks() {
    return Column(
      children: [
        // Lien vers inscription
        TextButton(
          onPressed: () => context.goToRegister(),
          child: const Text(
            'Pas encore de compte ? Inscrivez-vous',
            style: TextStyle(color: Colors.white),
          ),
        ),

        // Lien mot de passe oublié
        TextButton(
          onPressed: _handleForgotPassword,
          child: const Text(
            'Mot de passe oublié ?',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  /// Validation de l'email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre email';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  /// Validation du mot de passe
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }
}
