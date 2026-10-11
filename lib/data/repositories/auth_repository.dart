import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather_outfit_advisor/data/services/auth_service.dart';

/// Репозиторий аутентификации
class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  User? get currentUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserCredential> register({
    required String email,
    required String password,
    String? name,
  }) =>
      _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );

  Future<UserCredential> login({
    required String email,
    required String password,
  }) =>
      _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<UserCredential?> signInWithGoogle() => _authService.signInWithGoogle();

  Future<void> logout() => _authService.signOut();
}
