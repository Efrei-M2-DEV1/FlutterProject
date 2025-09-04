import 'package:flutter/foundation.dart';

/// Service d'authentification simple (en attendant Firebase)
///
/// Credentials génériques pour tester l'app :
/// Email: admin@todolist.com
/// Password: 123456
class AuthService extends ChangeNotifier {
  // ===== CREDENTIALS GÉNÉRIQUES =====
  static const String _validEmail = 'admin@todolist.com';
  static const String _validPassword = '123456';

  // ===== ÉTAT D'AUTHENTIFICATION =====
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _currentUserEmail;

  // ===== GETTERS =====
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get currentUserEmail => _currentUserEmail;

  /// Connexion avec email/password
  Future<AuthResult> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulation d'une requête réseau
    await Future.delayed(const Duration(milliseconds: 1500));

    // Vérification des credentials
    if (email.trim().toLowerCase() == _validEmail &&
        password == _validPassword) {
      _isLoggedIn = true;
      _currentUserEmail = email;
      _isLoading = false;
      notifyListeners();
      return AuthResult.success();
    } else {
      _isLoading = false;
      notifyListeners();
      return AuthResult.error('Email ou mot de passe incorrect');
    }
  }

  /// Inscription (simulation)
  Future<AuthResult> register(
    String email,
    String password,
    String name,
  ) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    // Pour la démo, on accepte n'importe quel email/password
    _isLoggedIn = true;
    _currentUserEmail = email;
    _isLoading = false;
    notifyListeners();
    return AuthResult.success();
  }

  /// Déconnexion
  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUserEmail = null;
    notifyListeners();
  }

  /// Vérifier si l'utilisateur est connecté au démarrage
  Future<void> checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Pour la démo, on considère que l'utilisateur n'est pas connecté
  }
}

/// Résultat d'une opération d'authentification
class AuthResult {
  final bool success;
  final String? errorMessage;

  AuthResult._(this.success, this.errorMessage);

  factory AuthResult.success() => AuthResult._(true, null);
  factory AuthResult.error(String message) => AuthResult._(false, message);
}
