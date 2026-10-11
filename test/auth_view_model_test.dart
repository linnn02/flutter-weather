import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit_advisor/ui/features/auth/auth_view_model.dart';
import 'package:weather_outfit_advisor/data/repositories/auth_repository.dart';
import 'package:weather_outfit_advisor/data/repositories/user_repository.dart';
import 'package:weather_outfit_advisor/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FakeUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  FakeUser({required this.uid, this.email, this.displayName});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUserCredential implements UserCredential {
  @override
  final User? user;

  FakeUserCredential({this.user});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthRepository implements AuthRepository {
  User? mockUser;
  bool shouldThrow = false;
  String throwCode = 'wrong-password';

  @override
  User? get currentUser => mockUser;

  @override
  Stream<User?> get authStateChanges => Stream.value(mockUser);

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    if (shouldThrow) {
      throw FirebaseAuthException(code: throwCode);
    }
    mockUser = FakeUser(uid: 'uid_123', email: email);
    return FakeUserCredential(user: mockUser);
  }

  @override
  Future<UserCredential> register({
    required String email,
    required String password,
    String? name,
  }) async {
    if (shouldThrow) {
      throw FirebaseAuthException(code: throwCode);
    }
    mockUser = FakeUser(uid: 'uid_123', email: email, displayName: name);
    return FakeUserCredential(user: mockUser);
  }

  @override
  Future<UserCredential?> signInWithGoogle() async {
    if (shouldThrow) {
      throw FirebaseAuthException(code: throwCode);
    }
    mockUser = FakeUser(
      uid: 'uid_google_123',
      email: 'google@test.com',
      displayName: 'Google Пользователь',
    );
    return FakeUserCredential(user: mockUser);
  }

  @override
  Future<void> logout() async {
    mockUser = null;
  }
}

class MockUserRepository implements UserRepository {
  final Map<String, UserModel> users = {};

  @override
  Future<void> createUserProfile(UserModel user) async {
    users[user.uid] = user;
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    return users[uid];
  }

  @override
  Future<void> updateUserSettings(String uid, Map<String, dynamic> settings) async {
    if (users.containsKey(uid)) {
      final current = users[uid]!;
      users[uid] = current.copyWith(
        theme: settings['theme'] as String?,
        temperatureUnit: settings['temperatureUnit'] as String?,
        language: settings['language'] as String?,
        notificationsEnabled: settings['notificationsEnabled'] as bool?,
      );
    }
  }
}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockUserRepository mockUserRepo;
  late AuthViewModel authViewModel;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockUserRepo = MockUserRepository();
    authViewModel = AuthViewModel(
      authRepository: mockAuthRepo,
      userRepository: mockUserRepo,
    );
  });

  group('AuthViewModel', () {
    test('initial state is unauthenticated when no user', () {
      expect(authViewModel.status, AuthStatus.unauthenticated);
      expect(authViewModel.isAuthenticated, isFalse);
      expect(authViewModel.currentUser, isNull);
    });

    test('login succeeds and updates auth state', () async {
      final result = await authViewModel.login(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      expect(authViewModel.status, AuthStatus.authenticated);
      expect(authViewModel.isAuthenticated, isTrue);
      expect(authViewModel.currentUser?.email, 'test@example.com');
      expect(authViewModel.errorMessage, isNull);
    });

    test('login failure sets error message', () async {
      mockAuthRepo.shouldThrow = true;
      mockAuthRepo.throwCode = 'wrong-password';

      final result = await authViewModel.login(
        email: 'test@example.com',
        password: 'wrong',
      );

      expect(result, isFalse);
      expect(authViewModel.status, AuthStatus.error);
      expect(authViewModel.isAuthenticated, isFalse);
      expect(authViewModel.errorMessage, contains('Неверный пароль'));
    });

    test('register validates password mismatch', () async {
      final result = await authViewModel.register(
        name: 'Алихан',
        email: 'user@test.com',
        password: 'password123',
        confirmPassword: 'different123',
      );

      expect(result, isFalse);
      expect(authViewModel.status, AuthStatus.error);
      expect(authViewModel.errorMessage, 'Пароли не совпадают');
    });

    test('register validates short password', () async {
      final result = await authViewModel.register(
        name: 'Алихан',
        email: 'user@test.com',
        password: '123',
        confirmPassword: '123',
      );

      expect(result, isFalse);
      expect(authViewModel.status, AuthStatus.error);
      expect(authViewModel.errorMessage, contains('не менее 6 символов'));
    });

    test('register succeeds, creates user in auth and profile in firestore', () async {
      final result = await authViewModel.register(
        name: 'Алихан',
        email: 'user@test.com',
        password: 'password123',
        confirmPassword: 'password123',
      );

      expect(result, isTrue);
      expect(authViewModel.isAuthenticated, isTrue);
      expect(authViewModel.currentUser?.displayName, 'Алихан');

      // Check Firestore document creation
      final profile = await mockUserRepo.getUserProfile('uid_123');
      expect(profile, isNotNull);
      expect(profile?.name, 'Алихан');
      expect(profile?.email, 'user@test.com');
      expect(profile?.temperatureUnit, 'celsius');
      expect(profile?.theme, 'system');
    });

    test('loginWithGoogle succeeds and creates profile in firestore if not exists', () async {
      final result = await authViewModel.loginWithGoogle();

      expect(result, isTrue);
      expect(authViewModel.isAuthenticated, isTrue);
      expect(authViewModel.currentUser?.email, 'google@test.com');
      expect(authViewModel.currentUser?.displayName, 'Google Пользователь');

      final profile = await mockUserRepo.getUserProfile('uid_google_123');
      expect(profile, isNotNull);
      expect(profile?.email, 'google@test.com');
      expect(profile?.name, 'Google Пользователь');
    });

    test('logout clears current user and changes state to unauthenticated', () async {
      await authViewModel.login(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(authViewModel.isAuthenticated, isTrue);

      await authViewModel.logout();
      expect(authViewModel.isAuthenticated, isFalse);
      expect(authViewModel.currentUser, isNull);
      expect(authViewModel.status, AuthStatus.unauthenticated);
    });
  });
}
