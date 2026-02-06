import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/forecast_model.dart';
import '../../data/datasources/weather_remote_data_source.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/network/http_client.dart';

enum WeatherStatus { initial, loading, success, error }
enum LocationPermissionStatus { denied, granted, permanentlyDenied }

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
  LocationPermissionStatus? _permissionStatus;
  bool _usingCurrentLocation = false;
  
  WeatherStatus get status => _status;
  WeatherModel? get weather => _weather;
  List<ForecastModel> get forecast => _forecast;
  String get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  bool get hasWeather => _weather != null;
  LocationPermissionStatus? get permissionStatus => _permissionStatus;
  bool get usingCurrentLocation => _usingCurrentLocation;
  
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
      _setError('No internet connection. Please check your connection and try again.');
      return;
    }
    
    _isOffline = false;
    _usingCurrentLocation = false;
    _setStatus(WeatherStatus.loading);
    
    try {
      // Call the actual API to get weather data
      _weather = await _dataSource.getCurrentWeather(city);
      
      // Get forecast data
      _forecast = await _dataSource.getForecast(city);
      
      _setStatus(WeatherStatus.success);
    } catch (e) {
      _setError('Failed to fetch weather: ${e.toString()}');
    }
  }
  
  Future<void> fetchWeatherByLocation() async {
    if (!await networkInfo.isConnected) {
      _isOffline = true;
      _setError('No internet connection. Please check your connection and try again.');
      return;
    }
    
    _isOffline = false;
    _setStatus(WeatherStatus.loading);
    
    try {
      // Check and request location permission
      PermissionStatus status = await Permission.location.request();
      
      if (status.isDenied) {
        _permissionStatus = LocationPermissionStatus.denied;
        _setError('Location permission is required to use current location.');
        return;
      } else if (status.isPermanentlyDenied) {
        _permissionStatus = LocationPermissionStatus.permanentlyDenied;
        _setError('Location permission is permanently denied. Please enable it in settings.');
        return;
      }
      
      _permissionStatus = LocationPermissionStatus.granted;
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      
      // Fetch weather using coordinates
      _weather = await _dataSource.getWeatherByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      // Get forecast data
      _forecast = await _dataSource.getForecastByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      _usingCurrentLocation = true;
      _setStatus(WeatherStatus.success);
    } on PermissionStatus catch (e) {
      _setError('Permission error: $e');
    } catch (e) {
      _setError('Failed to get location: $e');
    }
  }

  
  
  void clearError() {
    _errorMessage = '';
    if (_status == WeatherStatus.error) {
      _setStatus(WeatherStatus.initial);
    }
  }
}