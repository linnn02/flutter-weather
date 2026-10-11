import 'package:flutter_test/flutter_test.dart';
import 'package:weather_outfit_advisor/data/repositories/favorites_repository.dart';
import 'package:weather_outfit_advisor/data/services/local_storage_service.dart';
import 'package:weather_outfit_advisor/data/services/firestore_service.dart';
import 'package:weather_outfit_advisor/data/models/user_model.dart';

class MockLocalStorageService implements LocalStorageService {
  List<String> cities = [];

  @override
  List<String> getFavoriteCities({String? userId}) => List.from(cities);

  @override
  Future<void> setFavoriteCities(List<String> newCities, {String? userId}) async {
    cities = List.from(newCities);
  }

  @override
  Future<void> addFavoriteCity(String cityName, {String? userId}) async {
    if (!cities.contains(cityName)) cities.add(cityName);
  }

  @override
  Future<void> removeFavoriteCity(String cityName, {String? userId}) async {
    cities.remove(cityName);
  }

  @override
  bool isFavorite(String cityName, {String? userId}) => cities.contains(cityName);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirestoreService implements FirestoreService {
  final Map<String, List<FavoriteCityModel>> userFavorites = {};

  @override
  Future<List<FavoriteCityModel>> getFavorites(String uid) async {
    return userFavorites[uid] ?? [];
  }

  @override
  Future<void> addFavorite(String uid, FavoriteCityModel favorite) async {
    userFavorites.putIfAbsent(uid, () => []);
    userFavorites[uid]!.removeWhere((f) => f.cityName == favorite.cityName);
    userFavorites[uid]!.add(favorite);
  }

  @override
  Future<void> removeFavorite(String uid, String cityName) async {
    userFavorites[uid]?.removeWhere((f) => f.cityName == cityName);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockLocalStorageService mockLocalStorage;
  late MockFirestoreService mockFirestore;
  late FavoritesRepository repository;

  setUp(() {
    mockLocalStorage = MockLocalStorageService();
    mockFirestore = MockFirestoreService();
    repository = FavoritesRepository(
      localStorageService: mockLocalStorage,
      firestoreService: mockFirestore,
      currentUserId: 'test_user_123',
    );
  });

  group('FavoritesRepository with Cloud Sync', () {
    test('getFavorites returns items from local storage', () {
      mockLocalStorage.cities = ['Алматы', 'Астана'];
      expect(repository.getFavorites(), ['Алматы', 'Астана']);
    });

    test('addFavorite saves to local storage and syncs to firestore for authenticated user', () async {
      await repository.addFavorite('Шымкент', lat: 42.3, lon: 69.6);

      expect(mockLocalStorage.isFavorite('Шымкент'), isTrue);
      final cloudCities = await mockFirestore.getFavorites('test_user_123');
      expect(cloudCities.any((c) => c.cityName == 'Шымкент'), isTrue);
    });

    test('removeFavorite removes from local storage and firestore', () async {
      await repository.addFavorite('Караганда');
      expect(mockLocalStorage.isFavorite('Караганда'), isTrue);

      await repository.removeFavorite('Караганда');
      expect(mockLocalStorage.isFavorite('Караганда'), isFalse);
      final cloudCities = await mockFirestore.getFavorites('test_user_123');
      expect(cloudCities.any((c) => c.cityName == 'Караганда'), isFalse);
    });

    test('syncFromCloud merges cloud cities into local storage and vice versa', () async {
      mockLocalStorage.cities = ['ЛокальныйГород'];
      await mockFirestore.addFavorite(
        'test_user_123',
        FavoriteCityModel(id: 'oblako', cityName: 'ОблачныйГород'),
      );

      final result = await repository.syncFromCloud();

      expect(result, contains('ЛокальныйГород'));
      expect(result, contains('ОблачныйГород'));
      final cloudCities = await mockFirestore.getFavorites('test_user_123');
      expect(cloudCities.any((c) => c.cityName == 'ЛокальныйГород'), isTrue);
    });

    test('unauthenticated user works strictly with local storage without errors', () async {
      repository.updateCurrentUser(null);

      await repository.addFavorite('Павлодар');
      expect(mockLocalStorage.isFavorite('Павлодар'), isTrue);

      await repository.removeFavorite('Павлодар');
      expect(mockLocalStorage.isFavorite('Павлодар'), isFalse);
    });
  });
}
