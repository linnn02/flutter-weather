/// Raw API model matching OpenWeatherMap /forecast response
class ForecastApiModel {
  final List<Map<String, dynamic>> list;
  final Map<String, dynamic> city;

  const ForecastApiModel({
    required this.list,
    required this.city,
  });

  factory ForecastApiModel.fromJson(Map<String, dynamic> json) {
    return ForecastApiModel(
      list:
          ((json['list'] as List<dynamic>?) ?? []).cast<Map<String, dynamic>>(),
      city: (json['city'] as Map<String, dynamic>?) ?? {},
    );
  }
}
