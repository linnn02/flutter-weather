import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:weather_outfit_advisor/data/models/weather_api_model.dart';
import 'package:weather_outfit_advisor/data/models/forecast_api_model.dart';

/// Service for communicating with OpenWeatherMap API
class WeatherApiService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'bcdb3f951557d812b028e7341103b745';
  static const String _units = 'metric';
  static const String _lang = 'ru';

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch current weather by city name
  Future<WeatherApiModel> fetchWeatherByCity(String cityName) async {
    final uri = Uri.parse('$_baseUrl/weather').replace(
      queryParameters: {
        'q': cityName,
        'appid': _apiKey,
        'units': _units,
        'lang': _lang,
      },
    );
    return _fetchWeather(uri);
  }

  /// Fetch current weather by coordinates
  Future<WeatherApiModel> fetchWeatherByCoords(
    double lat,
    double lon,
  ) async {
    final uri = Uri.parse('$_baseUrl/weather').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': _apiKey,
        'units': _units,
        'lang': _lang,
      },
    );
    return _fetchWeather(uri);
  }

  Future<WeatherApiModel> _fetchWeather(Uri uri) async {
    try {
      final response = await _client.get(uri, headers: {
        HttpHeaders.acceptHeader: 'application/json',
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherApiModel.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception('Неверный API ключ. Проверьте настройки.');
      } else if (response.statusCode == 404) {
        throw Exception('Город не найден. Проверьте название.');
      } else {
        throw Exception(
          'Ошибка загрузки погоды: ${response.statusCode}',
        );
      }
    } on SocketException {
      throw Exception('Нет интернет-соединения.');
    } on HttpException {
      throw Exception('Ошибка HTTP при загрузке погоды.');
    } on FormatException {
      throw Exception('Ошибка разбора ответа сервера.');
    }
  }

  /// Fetch 5-day forecast (3h intervals) by city
  Future<ForecastApiModel> fetchForecastByCity(String cityName) async {
    final uri = Uri.parse('$_baseUrl/forecast').replace(
      queryParameters: {
        'q': cityName,
        'appid': _apiKey,
        'units': _units,
        'lang': _lang,
        'cnt': '40',
      },
    );
    return _fetchForecast(uri);
  }

  /// Fetch 5-day forecast by coordinates
  Future<ForecastApiModel> fetchForecastByCoords(
    double lat,
    double lon,
  ) async {
    final uri = Uri.parse('$_baseUrl/forecast').replace(
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': _apiKey,
        'units': _units,
        'lang': _lang,
        'cnt': '40',
      },
    );
    return _fetchForecast(uri);
  }

  Future<ForecastApiModel> _fetchForecast(Uri uri) async {
    try {
      final response = await _client.get(uri, headers: {
        HttpHeaders.acceptHeader: 'application/json',
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ForecastApiModel.fromJson(json);
      } else {
        throw Exception('Ошибка загрузки прогноза: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Нет интернет-соединения.');
    }
  }

  void dispose() {
    _client.close();
  }
}
