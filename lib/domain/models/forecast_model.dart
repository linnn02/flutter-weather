/// Domain model for hourly forecast item
class HourlyForecastModel {
  final DateTime dateTime;
  final double temperature;
  final double feelsLike;
  final double precipitationProbability;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final double windSpeed;
  final int humidity;

  const HourlyForecastModel({
    required this.dateTime,
    required this.temperature,
    required this.feelsLike,
    required this.precipitationProbability,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.windSpeed,
    required this.humidity,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    return HourlyForecastModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['dt'] as int) * 1000,
      ),
      temperature: ((json['main'] as Map<String, dynamic>?)?['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: ((json['main'] as Map<String, dynamic>?)?['feels_like'] as num?)?.toDouble() ?? 0.0,
      precipitationProbability: (json['pop'] as num?)?.toDouble() ?? 0.0,
      weatherMain: ((json['weather'] as List<dynamic>?)?.isNotEmpty == true
          ? (json['weather'] as List<dynamic>)[0]['main'] as String?
          : null) ?? '',
      weatherDescription: ((json['weather'] as List<dynamic>?)?.isNotEmpty == true
          ? (json['weather'] as List<dynamic>)[0]['description'] as String?
          : null) ?? '',
      weatherIcon: ((json['weather'] as List<dynamic>?)?.isNotEmpty == true
          ? (json['weather'] as List<dynamic>)[0]['icon'] as String?
          : null) ?? '01d',
      windSpeed: ((json['wind'] as Map<String, dynamic>?)?['speed'] as num?)?.toDouble() ?? 0.0,
      humidity: ((json['main'] as Map<String, dynamic>?)?['humidity'] as num?)?.toInt() ?? 0,
    );
  }

  String get iconUrl =>
      'https://openweathermap.org/img/wn/$weatherIcon@2x.png';
}

/// Domain model for daily forecast item
class DailyForecastModel {
  final DateTime date;
  final double tempDay;
  final double tempNight;
  final double tempMin;
  final double tempMax;
  final double precipitationProbability;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final double windSpeed;
  final int humidity;

  const DailyForecastModel({
    required this.date,
    required this.tempDay,
    required this.tempNight,
    required this.tempMin,
    required this.tempMax,
    required this.precipitationProbability,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.windSpeed,
    required this.humidity,
  });

  /// Aggregate hourly forecasts into daily summaries
  static List<DailyForecastModel> fromHourlyList(
    List<HourlyForecastModel> hourly,
  ) {
    final Map<String, List<HourlyForecastModel>> grouped = {};
    for (final h in hourly) {
      final key =
          '${h.dateTime.year}-${h.dateTime.month}-${h.dateTime.day}';
      grouped.putIfAbsent(key, () => []).add(h);
    }

    return grouped.entries.map((e) {
      final items = e.value;
      final temps = items.map((i) => i.temperature).toList();
      final dayItems = items.where((i) => i.dateTime.hour >= 9 && i.dateTime.hour <= 18).toList();
      final nightItems = items.where((i) => i.dateTime.hour < 9 || i.dateTime.hour > 18).toList();

      return DailyForecastModel(
        date: items.first.dateTime,
        tempDay: dayItems.isNotEmpty
            ? dayItems.map((i) => i.temperature).reduce((a, b) => a + b) / dayItems.length
            : temps.reduce((a, b) => a + b) / temps.length,
        tempNight: nightItems.isNotEmpty
            ? nightItems.map((i) => i.temperature).reduce((a, b) => a + b) / nightItems.length
            : temps.reduce((a, b) => a + b) / temps.length,
        tempMin: temps.reduce((a, b) => a < b ? a : b),
        tempMax: temps.reduce((a, b) => a > b ? a : b),
        precipitationProbability: items.map((i) => i.precipitationProbability).reduce((a, b) => a > b ? a : b),
        weatherMain: items.first.weatherMain,
        weatherDescription: items.first.weatherDescription,
        weatherIcon: items.first.weatherIcon,
        windSpeed: items.map((i) => i.windSpeed).reduce((a, b) => a + b) / items.length,
        humidity: (items.map((i) => i.humidity).reduce((a, b) => a + b) / items.length).round(),
      );
    }).toList();
  }

  String get iconUrl =>
      'https://openweathermap.org/img/wn/$weatherIcon@2x.png';
}
