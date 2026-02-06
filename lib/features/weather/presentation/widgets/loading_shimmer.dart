import 'package:flutter/material.dart';
import '../../../../shared/widgets/lottie_weather_loading.dart';
import '../../data/models/weather_model.dart';
import '../../domain/entities/weather_condition.dart';

class LoadingShimmer extends StatelessWidget {
  final WeatherModel? currentWeather;
  
  const LoadingShimmer({super.key, this.currentWeather});

  @override
  Widget build(BuildContext context) {
    // Determine condition based on current weather or use generic
    final condition = _getConditionFromWeather(currentWeather);
    
    return LottieWeatherLoading(
      condition: condition,
      message: _getLoadingMessage(condition),
    );
  }

  WeatherCondition _getConditionFromWeather(WeatherModel? weather) {
    if (weather == null) return WeatherCondition.misty;
    
    final desc = weather.description.toLowerCase();
    if (desc.contains('clear') || desc.contains('sun')) {
      return WeatherCondition.clear;
    } else if (desc.contains('cloud')) {
      return WeatherCondition.cloudy;
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return WeatherCondition.rainy;
    } else if (desc.contains('snow') || desc.contains('ice')) {
      return WeatherCondition.snowy;
    } else if (desc.contains('thunder') || desc.contains('storm')) {
      return WeatherCondition.thunderstorm;
    }
    
    return WeatherCondition.misty;
  }

  String _getLoadingMessage(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return 'Basking in the sunshine data... ☀️';
      case WeatherCondition.cloudy:
        return 'Gathering cloud formations... ☁️';
      case WeatherCondition.rainy:
        return 'Measuring raindrops... 🌧️';
      case WeatherCondition.snowy:
        return 'Counting snowflakes... ❄️';
      case WeatherCondition.thunderstorm:
        return 'Tracking lightning bolts... ⚡';
      case WeatherCondition.misty:
        return 'Reading the mist... 🌫️';
      case WeatherCondition.smoke:
      default:
        return 'Loading weather magic... ✨';
    }
  }
}