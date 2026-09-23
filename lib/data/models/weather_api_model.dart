/// Raw API model matching OpenWeatherMap /weather response
class WeatherApiModel {
  final String name;
  final Map<String, dynamic> sys;
  final Map<String, dynamic> coord;
  final Map<String, dynamic> main;
  final Map<String, dynamic> wind;
  final int visibility;
  final Map<String, dynamic> clouds;
  final List<Map<String, dynamic>> weather;

  const WeatherApiModel({
    required this.name,
    required this.sys,
    required this.coord,
    required this.main,
    required this.wind,
    required this.visibility,
    required this.clouds,
    required this.weather,
  });

  factory WeatherApiModel.fromJson(Map<String, dynamic> json) {
    return WeatherApiModel(
      name: json['name'] as String? ?? '',
      sys: (json['sys'] as Map<String, dynamic>?) ?? {},
      coord: (json['coord'] as Map<String, dynamic>?) ?? {},
      main: (json['main'] as Map<String, dynamic>?) ?? {},
      wind: (json['wind'] as Map<String, dynamic>?) ?? {},
      visibility: json['visibility'] as int? ?? 0,
      clouds: (json['clouds'] as Map<String, dynamic>?) ?? {},
      weather: ((json['weather'] as List<dynamic>?) ?? [])
          .cast<Map<String, dynamic>>(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sys': sys,
        'coord': coord,
        'main': main,
        'wind': wind,
        'visibility': visibility,
        'clouds': clouds,
        'weather': weather,
      };
}
