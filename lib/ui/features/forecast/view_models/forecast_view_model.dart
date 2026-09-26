import 'package:flutter/material.dart';
import 'package:weather_outfit_advisor/data/repositories/weather_repository.dart';
import 'package:weather_outfit_advisor/domain/models/forecast_model.dart';

enum ForecastState { initial, loading, success, error }

/// ViewModel for the forecast screen
class ForecastViewModel extends ChangeNotifier {
  final WeatherRepository _weatherRepository;

  ForecastViewModel({required WeatherRepository weatherRepository})
      : _weatherRepository = weatherRepository;

  ForecastState _state = ForecastState.initial;
  ForecastState get state => _state;

  List<HourlyForecastModel> _hourlyForecast = [];
  List<HourlyForecastModel> get hourlyForecast => _hourlyForecast;

  List<DailyForecastModel> _dailyForecast = [];
  List<DailyForecastModel> get dailyForecast => _dailyForecast;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _currentCity = '';

  Future<void> loadForecast(String cityName) async {
    if (cityName == _currentCity && _state == ForecastState.success) return;
    _currentCity = cityName;
    _state = ForecastState.loading;
    notifyListeners();

    try {
      _hourlyForecast = await _weatherRepository.getHourlyForecast(cityName);
      _dailyForecast = await _weatherRepository.getDailyForecast(cityName);
      _state = ForecastState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = ForecastState.error;
    }
    notifyListeners();
  }
}
