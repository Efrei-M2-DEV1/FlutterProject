import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../data/auth_service.dart';

/// Écran d'inscription moderne et élégant
///
/// Fonctionnalités :
/// - Design moderne avec gradient
/// - Formulaire avec validation
/// - Animation et feedback utilisateur
/// - Navigation fluide
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // Contrôleurs pour les champs de texte
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // États du formulaire
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Fonction d'inscription
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Utiliser le service d'authentification fourni par Provider
    final authService = context.read<AuthService>();
    final result = await authService.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie !'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigation vers les tâches
      context.goToTasks();
    } else {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Erreur lors de l\'inscription'),
          backgroundColor: Colors.red,
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
          const SizedBox(height: 40),

          // ===== HEADER AVEC LOGO =====
          _buildHeader(),

          const SizedBox(height: 40),

          // ===== FORMULAIRE D'INSCRIPTION =====
          _buildRegisterForm(),

          const SizedBox(height: 24),

          // ===== LIEN VERS CONNEXION =====
          _buildLoginLink(),
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
            Icons.person_add_rounded,
            size: 50,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 24),

        // Titre principal
        const Text(
          'Créer un compte',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        // Sous-titre
        const Text(
          'Rejoignez-nous et organisez vos tâches',
          style: TextStyle(fontSize: 16, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Formulaire d'inscription
  Widget _buildRegisterForm() {
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
              'Inscription',
              style: AppTextStyles.titleLarge(context),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Remplissez les informations ci-dessous',
              style: AppTextStyles.bodyMedium(context),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Champ nom
            CustomTextField(
              controller: _nameController,
              label: 'Nom complet',
              hint: 'Votre nom complet',
              keyboardType: TextInputType.name,
              prefixIcon: Icons.person_outlined,
              validator: _validateName,
            ),

            const SizedBox(height: 16),

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

            const SizedBox(height: 16),

            // Champ confirmation mot de passe
            CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirmer le mot de passe',
              hint: 'Confirmez votre mot de passe',
              prefixIcon: Icons.lock_outlined,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
              ),
              validator: _validateConfirmPassword,
            ),

            const SizedBox(height: 24),

            // Bouton d'inscription
            CustomButton(
              onPressed: _isLoading ? null : _handleRegister,
              isLoading: _isLoading,
              child: const Text('S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }

  /// Lien vers la page de connexion
  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => context.goToLogin(),
      child: const Text(
        'Déjà un compte ? Connectez-vous',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  /// Validation du nom
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre nom';
    }
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
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

  /// Validation de la confirmation du mot de passe
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }
}
