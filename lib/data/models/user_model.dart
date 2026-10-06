import 'package:cloud_firestore/cloud_firestore.dart';

/// Модель данных профиля пользователя для Firestore
class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final String temperatureUnit;
  final String language;
  final String theme;
  final bool notificationsEnabled;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.temperatureUnit = 'celsius',
    this.language = 'ru',
    this.theme = 'system',
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'temperatureUnit': temperatureUnit,
      'language': language,
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    DateTime created;
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is Timestamp) {
      created = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      created = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    return UserModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      createdAt: created,
      temperatureUnit: map['temperatureUnit'] as String? ?? 'celsius',
      language: map['language'] as String? ?? 'ru',
      theme: map['theme'] as String? ?? 'system',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    DateTime? createdAt,
    String? temperatureUnit,
    String? language,
    String? theme,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

/// Модель избранного города для Firestore
class FavoriteCityModel {
  final String id;
  final String cityName;
  final double? latitude;
  final double? longitude;
  final DateTime addedAt;

  FavoriteCityModel({
    required this.id,
    required this.cityName,
    this.latitude,
    this.longitude,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'cityName': cityName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  factory FavoriteCityModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime added;
    final rawAddedAt = map['addedAt'];
    if (rawAddedAt is Timestamp) {
      added = rawAddedAt.toDate();
    } else if (rawAddedAt is String) {
      added = DateTime.tryParse(rawAddedAt) ?? DateTime.now();
    } else {
      added = DateTime.now();
    }

    return FavoriteCityModel(
      id: id,
      cityName: map['cityName'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      addedAt: added,
    );
  }
}
