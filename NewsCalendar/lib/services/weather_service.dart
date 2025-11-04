import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/weather.dart';

/// Service for fetching weather data from OpenWeatherMap API
class WeatherService {
  static const String _apiKey = 'c62d87d60e1ca84b95b47d84f21c8734';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  /// Get current location using GPS
  /// Returns Position object with latitude and longitude
  /// Throws exception if location permission is denied or GPS is unavailable
  Future<Position> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied. Please enable location access in settings.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied. Please enable location access in app settings.');
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 10),
    );

    return position;
  }

  /// Fetch weather data for given latitude and longitude
  Future<Weather> getWeatherData(double latitude, double longitude) async {
    final url = Uri.parse('$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return Weather.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your OpenWeatherMap API key.');
      } else if (response.statusCode == 404) {
        throw Exception('Weather data not found for this location.');
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Get weather data for current location
  /// This method combines GPS location fetching and weather API call
  Future<Weather> getCurrentWeather() async {
    try {
      // Get current location
      final position = await getCurrentLocation();
      
      // Fetch weather data
      return await getWeatherData(position.latitude, position.longitude);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to get current weather: $e');
    }
  }
}

