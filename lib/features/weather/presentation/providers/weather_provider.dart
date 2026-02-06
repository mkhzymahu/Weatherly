import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../data/models/weather_model.dart';
import '../../data/models/forecast_model.dart';
import '../../data/datasources/weather_remote_data_source.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/network/http_client.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherProvider extends ChangeNotifier {
  final NetworkInfo networkInfo;
  late final WeatherRemoteDataSource _dataSource;
  
  WeatherProvider({required this.networkInfo}) {
    // Initialize the data source with HttpClient
    _dataSource = WeatherRemoteDataSourceImpl(
      httpClient: HttpClient(client: http.Client()),
    );
  }
  
  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _weather;
  List<ForecastModel> _forecast = [];
  String _errorMessage = '';
  bool _isOffline = false;
  
  WeatherStatus get status => _status;
  WeatherModel? get weather => _weather;
  List<ForecastModel> get forecast => _forecast;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  bool get hasWeather => _weather != null;
  
  void _setStatus(WeatherStatus status) {
    _status = status;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    _setStatus(WeatherStatus.error);
  }
  
  Future<void> fetchWeather(String city) async {
    if (!await networkInfo.isConnected) {
      _isOffline = true;
      _setError('No internet connection');
      return;
    }
    
    _isOffline = false;
    _setStatus(WeatherStatus.loading);
    
    try {
      // Call the actual API to get weather data
      _weather = await _dataSource.getCurrentWeather(city);
      
      // Get forecast data
      _forecast = await _dataSource.getForecast(city);
      
      _setStatus(WeatherStatus.success);
    } catch (e) {
      _setError('Failed to fetch weather data: $e');
    }
  }
  
  Future<void> fetchWeatherByLocation() async {
    // This would use geolocator to get current location
    // For now, we'll use a default city
    await fetchWeather('London');
  }

  
  
  void clearError() {
    _errorMessage = '';
    if (_status == WeatherStatus.error) {
      _setStatus(WeatherStatus.initial);
    }
  }
}