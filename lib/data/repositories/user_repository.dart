import 'package:weather_outfit_advisor/data/models/user_model.dart';
import 'package:weather_outfit_advisor/data/services/firestore_service.dart';

/// Репозиторий профиля и настроек пользователя в Firestore
class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Future<void> createUserProfile(UserModel user) =>
      _firestoreService.createUserProfile(user);

  Future<UserModel?> getUserProfile(String uid) =>
      _firestoreService.getUserProfile(uid);

  Future<void> updateUserSettings(String uid, Map<String, dynamic> settings) =>
      _firestoreService.updateUserSettings(uid, settings);
}
