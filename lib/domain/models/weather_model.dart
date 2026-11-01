/// Domain model for current weather data
class WeatherModel {
  final String cityName;
  final String countryCode;
  final double latitude;
  final double longitude;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final int windDegree;
  final int visibility;
  final int pressure;
  final int clouds;
  final String weatherMain;
  final String weatherDescription;
  final String weatherIcon;
  final int sunrise;
  final int sunset;
  final DateTime timestamp;

  const WeatherModel({
    required this.cityName,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDegree,
    required this.visibility,
    required this.pressure,
    required this.clouds,
    required this.weatherMain,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.sunrise,
    required this.sunset,
    required this.timestamp,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] as String? ?? '',
      countryCode:
          (json['sys'] as Map<String, dynamic>?)?['country'] as String? ?? '',
      latitude: ((json['coord'] as Map<String, dynamic>?)?['lat'] as num?)
              ?.toDouble() ??
          0.0,
      longitude: ((json['coord'] as Map<String, dynamic>?)?['lon'] as num?)
              ?.toDouble() ??
          0.0,
      temperature: ((json['main'] as Map<String, dynamic>?)?['temp'] as num?)
              ?.toDouble() ??
          0.0,
      feelsLike:
          ((json['main'] as Map<String, dynamic>?)?['feels_like'] as num?)
                  ?.toDouble() ??
              0.0,
      tempMin: ((json['main'] as Map<String, dynamic>?)?['temp_min'] as num?)
              ?.toDouble() ??
          0.0,
      tempMax: ((json['main'] as Map<String, dynamic>?)?['temp_max'] as num?)
              ?.toDouble() ??
          0.0,
      humidity:
          (json['main'] as Map<String, dynamic>?)?['humidity'] as int? ?? 0,
      windSpeed: ((json['wind'] as Map<String, dynamic>?)?['speed'] as num?)
              ?.toDouble() ??
          0.0,
      windDegree: (json['wind'] as Map<String, dynamic>?)?['deg'] as int? ?? 0,
      visibility: json['visibility'] as int? ?? 0,
      pressure: ((json['main'] as Map<String, dynamic>?)?['pressure'] as num?)
              ?.toInt() ??
          0,
      clouds: ((json['clouds'] as Map<String, dynamic>?)?['all'] as num?)
              ?.toInt() ??
          0,
      weatherMain: ((json['weather'] as List<dynamic>?)?.isNotEmpty == true
              ? (json['weather'] as List<dynamic>)[0]['main'] as String?
              : null) ??
          '',
      weatherDescription: ((json['weather'] as List<dynamic>?)?.isNotEmpty ==
                  true
              ? (json['weather'] as List<dynamic>)[0]['description'] as String?
              : null) ??
          '',
      weatherIcon: ((json['weather'] as List<dynamic>?)?.isNotEmpty == true
              ? (json['weather'] as List<dynamic>)[0]['icon'] as String?
              : null) ??
          '01d',
      sunrise: ((json['sys'] as Map<String, dynamic>?)?['sunrise'] as num?)
              ?.toInt() ??
          0,
      sunset: ((json['sys'] as Map<String, dynamic>?)?['sunset'] as num?)
              ?.toInt() ??
          0,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': cityName,
      'sys': {'country': countryCode, 'sunrise': sunrise, 'sunset': sunset},
      'coord': {'lat': latitude, 'lon': longitude},
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'humidity': humidity,
        'pressure': pressure,
      },
      'wind': {'speed': windSpeed, 'deg': windDegree},
      'visibility': visibility,
      'clouds': {'all': clouds},
      'weather': [
        {
          'main': weatherMain,
          'description': weatherDescription,
          'icon': weatherIcon,
        }
      ],
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isDay {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now > sunrise && now < sunset;
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$weatherIcon@2x.png';

  WeatherModel copyWith({
    String? cityName,
    String? countryCode,
    double? latitude,
    double? longitude,
    double? temperature,
    double? feelsLike,
    double? tempMin,
    double? tempMax,
    int? humidity,
    double? windSpeed,
    int? windDegree,
    int? visibility,
    int? pressure,
    int? clouds,
    String? weatherMain,
    String? weatherDescription,
    String? weatherIcon,
    int? sunrise,
    int? sunset,
    DateTime? timestamp,
  }) {
    return WeatherModel(
      cityName: cityName ?? this.cityName,
      countryCode: countryCode ?? this.countryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      windDegree: windDegree ?? this.windDegree,
      visibility: visibility ?? this.visibility,
      pressure: pressure ?? this.pressure,
      clouds: clouds ?? this.clouds,
      weatherMain: weatherMain ?? this.weatherMain,
      weatherDescription: weatherDescription ?? this.weatherDescription,
      weatherIcon: weatherIcon ?? this.weatherIcon,
      sunrise: sunrise ?? this.sunrise,
      sunset: sunset ?? this.sunset,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
