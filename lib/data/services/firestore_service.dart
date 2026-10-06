import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weather_outfit_advisor/data/models/user_model.dart';

/// Сервис для работы с Cloud Firestore
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Создать или обновить профиль пользователя
  Future<void> createUserProfile(UserModel user) async {
    await _usersCollection.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  /// Получить профиль пользователя
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  /// Обновить отдельные настройки пользователя в документе
  Future<void> updateUserSettings(String uid, Map<String, dynamic> settings) async {
    await _usersCollection.doc(uid).set(settings, SetOptions(merge: true));
  }

  // ─── Избранные города (подколлекция users/{uid}/favorites) ──────────────────

  CollectionReference<Map<String, dynamic>> _favoritesCollection(String uid) =>
      _usersCollection.doc(uid).collection('favorites');

  /// Получить все избранные города пользователя из Firestore
  Future<List<FavoriteCityModel>> getFavorites(String uid) async {
    final snapshot = await _favoritesCollection(uid).get();
    return snapshot.docs
        .map((doc) => FavoriteCityModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Добавить избранный город
  Future<void> addFavorite(String uid, FavoriteCityModel favorite) async {
    // В качестве id документа используем нормализованное имя города, чтобы избежать дубликатов
    final docId = favorite.cityName.toLowerCase().replaceAll(' ', '_');
    await _favoritesCollection(uid).doc(docId).set(favorite.toMap(), SetOptions(merge: true));
  }

  /// Удалить избранный город
  Future<void> removeFavorite(String uid, String cityName) async {
    final docId = cityName.toLowerCase().replaceAll(' ', '_');
    await _favoritesCollection(uid).doc(docId).delete();
  }
}
