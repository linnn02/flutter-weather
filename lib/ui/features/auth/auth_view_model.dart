import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:weather_outfit_advisor/data/repositories/auth_repository.dart';
import 'package:weather_outfit_advisor/data/repositories/user_repository.dart';
import 'package:weather_outfit_advisor/data/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// ViewModel для управления аутентификацией и регистрацией
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository {
    _currentUser = _authRepository.currentUser;
    _status = _currentUser != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    if (_currentUser != null) {
      loadUserProfile();
    }
    _authSubscription =
        _authRepository.authStateChanges.listen(_onAuthStateChanged);
  }

  dynamic _authSubscription;
  User? _currentUser;
  User? get currentUser => _currentUser;

  UserModel? _userProfile;
  UserModel? get userProfile => _userProfile;

  String? get displayName {
    if (_userProfile?.name != null && _userProfile!.name.trim().isNotEmpty) {
      return _userProfile!.name.trim();
    }
    if (_currentUser?.displayName != null &&
        _currentUser!.displayName!.trim().isNotEmpty) {
      return _currentUser!.displayName!.trim();
    }
    return null;
  }

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _currentUser != null;

  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    _status =
        user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    if (user != null) {
      loadUserProfile();
    } else {
      _userProfile = null;
    }
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
    final user = _currentUser;
    if (user == null) {
      _userProfile = null;
      notifyListeners();
      return;
    }

    try {
      final profile = await _userRepository.getUserProfile(user.uid);
      if (profile != null) {
        _userProfile = profile;
      } else {
        final fallbackName = user.displayName?.isNotEmpty == true
            ? user.displayName!
            : (user.email?.isNotEmpty == true
                ? user.email!.split('@').first
                : 'Пользователь');
        final newProfile = UserModel(
          uid: user.uid,
          name: fallbackName,
          email: user.email ?? '',
          createdAt: DateTime.now(),
          temperatureUnit: 'celsius',
          language: 'ru',
          theme: 'system',
          notificationsEnabled: true,
        );
        await _userRepository.createUserProfile(newProfile);
        _userProfile = newProfile;
      }
      notifyListeners();
    } catch (_) {
      // Игнорируем сетевые ошибки, чтобы не блокировать интерфейс
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Вход в систему с email и паролем
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authRepository.login(
        email: email,
        password: password,
      );
      _currentUser = credential.user;
      _status = AuthStatus.authenticated;
      await loadUserProfile();
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapFirebaseAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Произошла непредвиденная ошибка: $e';
      notifyListeners();
      return false;
    }
  }

  /// Регистрация нового аккаунта
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().isEmpty) {
      _errorMessage = 'Введите ваше имя';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Пароли не совпадают';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Пароль должен содержать не менее 6 символов';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authRepository.register(
        email: email,
        password: password,
        name: name.trim(),
      );

      final user = credential.user;
      if (user != null) {
        // Создаем профиль пользователя в Firestore
        final userModel = UserModel(
          uid: user.uid,
          name: name.trim(),
          email: email.trim(),
          createdAt: DateTime.now(),
          temperatureUnit: 'celsius',
          language: 'ru',
          theme: 'system',
          notificationsEnabled: true,
        );
        _userProfile = userModel;
        await _userRepository.createUserProfile(userModel);
      }

      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapFirebaseAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Ошибка регистрации: $e';
      notifyListeners();
      return false;
    }
  }

  /// Вход через Google аккаунт
  Future<bool> loginWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authRepository.signInWithGoogle();
      if (credential == null) {
        // Отмена пользователем
        _status = _currentUser != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final user = credential.user;
      if (user != null) {
        // Проверяем, существует ли уже профиль в Firestore
        final existingProfile = await _userRepository.getUserProfile(user.uid);
        if (existingProfile == null) {
          final userModel = UserModel(
            uid: user.uid,
            name: user.displayName ?? 'Google User',
            email: user.email ?? '',
            createdAt: DateTime.now(),
            temperatureUnit: 'celsius',
            language: 'ru',
            theme: 'system',
            notificationsEnabled: true,
          );
          await _userRepository.createUserProfile(userModel);
        }
      }

      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _mapFirebaseAuthError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      final errorStr = e.toString();
      if (errorStr.contains('MissingPluginException') ||
          errorStr.contains('No implementation found')) {
        _errorMessage =
            'Вход через Google предназначен для Android и iOS. На Windows используйте Email и пароль.';
      } else {
        _errorMessage = 'Ошибка входа через Google: $e';
      }
      notifyListeners();
      return false;
    }
  }

  /// Выход из аккаунта
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      await _authRepository.logout();
      _currentUser = null;
      _userProfile = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = 'Ошибка выхода: $e';
      notifyListeners();
    }
  }

  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Пользователь с таким email не найден';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неверный пароль или email';
      case 'email-already-in-use':
        return 'Этот адрес email уже зарегистрирован';
      case 'invalid-email':
        return 'Некорректный формат email адреса';
      case 'weak-password':
        return 'Слишком слабый пароль (минимум 6 символов)';
      case 'network-request-failed':
        return 'Ошибка сети. Проверьте подключение к интернету';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      default:
        return 'Ошибка авторизации ($code)';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
