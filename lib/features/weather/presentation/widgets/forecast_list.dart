import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/forecast_model.dart';

class ForecastList extends StatelessWidget {
  final List<ForecastModel> forecasts;

  const ForecastList({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    // Take only 7 days for the forecast
    final dailyForecasts = _getDailyForecasts(forecasts);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '7-Day Forecast',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Next 7 Days',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Forecast items
            ...dailyForecasts.take(7).map((forecast) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ForecastItem(forecast: forecast),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  List<ForecastModel> _getDailyForecasts(List<ForecastModel> forecasts) {
    if (forecasts.isEmpty) return [];

    final Map<String, ForecastModel> dailyMap = {};
    
    for (final forecast in forecasts) {
      final dateKey = DateFormat('yyyy-MM-dd').format(forecast.date);
      
      if (!dailyMap.containsKey(dateKey)) {
        dailyMap[dateKey] = forecast;
      }
    }
    
    return dailyMap.values.toList();
  }
}

class ForecastItem extends StatelessWidget {
  final ForecastModel forecast;

  const ForecastItem({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Day
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forecast.dayOfWeek,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d').format(forecast.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Weather icon
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                children: [
                  Image.network(
                    'https://openweathermap.org/img/wn/${forecast.icon}.png',
                    width: 40,
                    height: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    forecast.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Temperature range
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${forecast.maxTemp.round()}°',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${forecast.minTemp.round()}°',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Humidity
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  size: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(height: 4),
                Text(
                  '${forecast.humidity}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}