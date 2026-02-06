import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';

class HttpClient {
  final http.Client client;

  HttpClient({required this.client});

  Future<dynamic> get(String url, Map<String, String> params) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: params);
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw NotFoundException('City not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException('Invalid API key');
      } else {
        throw ServerException('Server error: ${response.statusCode}');
      }
    } on FormatException {
      throw ServerException('Invalid response format');
    } catch (e) {
      throw ServerException('Network error: $e');
    }
  }
}