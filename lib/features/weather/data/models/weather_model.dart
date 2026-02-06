import 'package:equatable/equatable.dart';

class WeatherModel extends Equatable {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final String description;
  final String icon;
  final DateTime dateTime;
  final double? minTemp;
  final double? maxTemp;

  const WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.dateTime,
    this.minTemp,
    this.maxTemp,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: json['main']['humidity'] as int,
      pressure: json['main']['pressure'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemp: (json['main']['temp_min'] as num?)?.toDouble(),
      maxTemp: (json['main']['temp_max'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
        cityName,
        temperature,
        feelsLike,
        humidity,
        pressure,
        windSpeed,
        description,
        icon,
        dateTime,
      ];
}