import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service d'authentification avec Firebase Auth
///
/// Gère la connexion, l'inscription et la déconnexion des utilisateurs
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== ÉTAT D'AUTHENTIFICATION =====
  bool _isLoading = false;
  String? _errorMessage;

  // ===== GETTERS =====
  bool get isLoggedIn => _auth.currentUser != null;
  bool get isLoading => _isLoading;
  String? get currentUserEmail => _auth.currentUser?.email;
  User? get currentUser => _auth.currentUser;
  String? get errorMessage => _errorMessage;

  /// Connexion avec email/password Firebase
  Future<AuthResult> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      String errorMsg;
      
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'Aucun utilisateur trouvé avec cet email';
          break;
        case 'wrong-password':
          errorMsg = 'Mot de passe incorrect';
          break;
        case 'invalid-email':
          errorMsg = 'Email invalide';
          break;
        case 'user-disabled':
          errorMsg = 'Ce compte a été désactivé';
          break;
        default:
          errorMsg = 'Erreur de connexion: ${e.message}';
      }
      
      _errorMessage = errorMsg;
      notifyListeners();
      return AuthResult.error(errorMsg);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur inattendue: $e';
      notifyListeners();
      return AuthResult.error(_errorMessage!);
    }
  }

  /// Inscription avec Firebase
  Future<AuthResult> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Mettre à jour le nom d'affichage
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      _isLoading = false;
      notifyListeners();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      String errorMsg;
      
      switch (e.code) {
        case 'weak-password':
          errorMsg = 'Le mot de passe est trop faible (min 6 caractères)';
          break;
        case 'email-already-in-use':
          errorMsg = 'Un compte existe déjà avec cet email';
          break;
        case 'invalid-email':
          errorMsg = 'Email invalide';
          break;
        default:
          errorMsg = 'Erreur d\'inscription: ${e.message}';
      }
      
      _errorMessage = errorMsg;
      notifyListeners();
      return AuthResult.error(errorMsg);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur inattendue: $e';
      notifyListeners();
      return AuthResult.error(_errorMessage!);
    }
  }

  /// Déconnexion Firebase
  Future<void> logout() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors de la déconnexion: $e';
      notifyListeners();
    }
  }

  /// Réinitialisation du mot de passe
  Future<AuthResult> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    // Simulation d'une requête réseau
    await Future.delayed(const Duration(milliseconds: 1500));

    // Validation basique de l'email
    if (email.trim().isEmpty || !email.contains('@')) {
      _isLoading = false;
      notifyListeners();
      return AuthResult.error('Email invalide');
    }

    _isLoading = false;
    notifyListeners();
    return AuthResult.success();
  }

  /// Vérifier si l'utilisateur est connecté au démarrage
  Future<void> checkAuthStatus() async {
    // Firebase Auth maintient automatiquement l'état de connexion
    notifyListeners();
  }

  /// Réinitialiser le mot de passe
  Future<AuthResult> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email.trim());

      _isLoading = false;
      notifyListeners();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      String errorMsg;
      
      switch (e.code) {
        case 'user-not-found':
          errorMsg = 'Aucun utilisateur trouvé avec cet email';
          break;
        case 'invalid-email':
          errorMsg = 'Email invalide';
          break;
        default:
          errorMsg = 'Erreur: ${e.message}';
      }
      
      _errorMessage = errorMsg;
      notifyListeners();
      return AuthResult.error(errorMsg);
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur inattendue: $e';
      notifyListeners();
      return AuthResult.error(_errorMessage!);
    }
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
