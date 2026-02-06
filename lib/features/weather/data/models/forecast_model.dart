import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class ForecastModel extends Equatable {
  final DateTime date;
  final double temperature;
  final double minTemp;
  final double maxTemp;
  final String description;
  final String icon;
  final int humidity;

  const ForecastModel({
    required this.date,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.icon,
    required this.humidity,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'] as int,
    );
  }

  String get dayOfWeek => DateFormat('EEEE').format(date);
  String get shortDay => DateFormat('E').format(date);

  @override
  List<Object?> get props => [
        date,
        temperature,
        minTemp,
        maxTemp,
        description,
        icon,
        humidity,
      ];
}