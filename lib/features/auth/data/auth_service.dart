import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  bool _isLoading = false;

  AuthService() {
    _auth.authStateChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get currentUserEmail => _user?.email;
  String? get userId => _user?.uid;

  Future<AuthResult> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = credential.user;
      _isLoading = false;
      notifyListeners();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return AuthResult.error(e.message ?? 'Erreur d\'authentification');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AuthResult.error(e.toString());
    }
  }

  Future<AuthResult> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = credential.user;

      if (_user != null) {
        try {
          await _firestore.collection('users').doc(_user!.uid).set({
            'email': _user!.email,
            'name': name,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } on FirebaseException catch (e) {
          _isLoading = false;
          notifyListeners();
          return AuthResult.error('Erreur Firestore: ${e.message} (${e.code})');
        }
      }

      _isLoading = false;
      notifyListeners();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return AuthResult.error(e.message ?? 'Erreur lors de l\'inscription');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AuthResult.error(e.toString());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<AuthResult> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email.trim());

      _isLoading = false;
      notifyListeners();
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return AuthResult.error(
        e.message ?? 'Erreur lors de la réinitialisation',
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return AuthResult.error(e.toString());
    }
  }

  Future<void> checkAuthStatus() async {
    _user = _auth.currentUser;
    notifyListeners();
  }
}

class AuthResult {
  final bool success;
  final String? errorMessage;

  AuthResult._(this.success, this.errorMessage);

  factory AuthResult.success() => AuthResult._(true, null);
  factory AuthResult.error(String message) => AuthResult._(false, message);
}
