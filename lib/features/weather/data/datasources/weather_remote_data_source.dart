import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/http_client.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(String cityName);
  Future<List<ForecastModel>> getForecast(String cityName);
  Future<WeatherModel> getWeatherByLocation(double lat, double lon);
  Future<WeatherModel> getWeatherByCoordinates(
      {required double latitude, required double longitude});
  Future<List<ForecastModel>> getForecastByCoordinates(
      {required double latitude, required double longitude});
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final HttpClient httpClient;

  WeatherRemoteDataSourceImpl({required this.httpClient});

  Map<String, String> _getBaseParams() {
    return {
      'appid': ApiConstants.apiKey,
      'units': 'metric', // For Celsius
    };
  }

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    final params = _getBaseParams()
      ..addAll({'q': cityName});
    
    final response = await httpClient.get(
      '${ApiConstants.baseUrl}${ApiConstants.currentWeather}',
      params,
    );
    
    return WeatherModel.fromJson(response);
  }

  @override
  Future<List<ForecastModel>> getForecast(String cityName) async {
    final params = _getBaseParams()
      ..addAll({'q': cityName});
    
    final response = await httpClient.get(
      '${ApiConstants.baseUrl}${ApiConstants.forecast}',
      params,
    );
    
    final List<dynamic> forecastList = response['list'];
    return forecastList
        .map((json) => ForecastModel.fromJson(json))
        .toList();
  }

  @override
  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    final params = _getBaseParams()
      ..addAll({
        'lat': lat.toString(),
        'lon': lon.toString(),
      });
    
    final response = await httpClient.get(
      '${ApiConstants.baseUrl}${ApiConstants.currentWeather}',
      params,
    );
    
    return WeatherModel.fromJson(response);
  }

  @override
  Future<WeatherModel> getWeatherByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    return getWeatherByLocation(latitude, longitude);
  }

  @override
  Future<List<ForecastModel>> getForecastByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    final params = _getBaseParams()
      ..addAll({
        'lat': latitude.toString(),
        'lon': longitude.toString(),
      });
    
    final response = await httpClient.get(
      '${ApiConstants.baseUrl}${ApiConstants.forecast}',
      params,
    );
    
    final List<dynamic> forecastList = response['list'];
    return forecastList
        .map((json) => ForecastModel.fromJson(json))
        .toList();
  }
}