/// Weather model for OpenWeatherMap API response
class Weather {
  final double temperature; // in Celsius
  final double feelsLike; // in Celsius
  final int humidity; // percentage
  final double windSpeed; // in km/h
  final String location; // city name
  final String description; // weather description
  final String icon; // weather icon code
  final int pressure; // in hPa
  final double? visibility; // in km
  final int? sunrise; // Unix timestamp
  final int? sunset; // Unix timestamp
  final String? country; // country code

  Weather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.location,
    required this.description,
    required this.icon,
    required this.pressure,
    this.visibility,
    this.sunrise,
    this.sunset,
    this.country,
  });

  /// Create Weather object from JSON response
  factory Weather.fromJson(Map<String, dynamic> json) {
    // Convert temperature from Kelvin to Celsius
    final tempKelvin = json['main']['temp'] as double;
    final tempCelsius = tempKelvin - 273.15;
    
    final feelsLikeKelvin = json['main']['feels_like'] as double;
    final feelsLikeCelsius = feelsLikeKelvin - 273.15;

    // Convert wind speed from m/s to km/h
    final windSpeedMs = (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0;
    final windSpeedKmh = windSpeedMs * 3.6;

    // Get weather description
    final weatherList = json['weather'] as List;
    final weatherData = weatherList.isNotEmpty ? weatherList[0] as Map<String, dynamic> : {};
    final description = weatherData['description'] as String? ?? 'N/A';
    final icon = weatherData['icon'] as String? ?? '01d';

    // Get location name
    final location = json['name'] as String? ?? 'Unknown Location';

    // Get visibility in km (API returns in meters)
    final visibilityMeters = json['visibility'] as int?;
    final visibilityKm = visibilityMeters != null ? visibilityMeters / 1000.0 : null;

    // Get sunrise/sunset times
    final sys = json['sys'] as Map<String, dynamic>?;
    final sunrise = sys?['sunrise'] as int?;
    final sunset = sys?['sunset'] as int?;
    final country = sys?['country'] as String?;

    return Weather(
      temperature: tempCelsius.roundToDouble(),
      feelsLike: feelsLikeCelsius.roundToDouble(),
      humidity: json['main']['humidity'] as int,
      windSpeed: windSpeedKmh.roundToDouble(),
      location: location,
      description: description,
      icon: icon,
      pressure: json['main']['pressure'] as int,
      visibility: visibilityKm,
      sunrise: sunrise,
      sunset: sunset,
      country: country,
    );
  }

  /// Calculate sunlight hours from sunrise and sunset
  double? get sunlightHours {
    if (sunrise == null || sunset == null) return null;
    final hours = (sunset! - sunrise!) / 3600.0;
    return hours.roundToDouble();
  }

  /// Format temperature as string with degree symbol
  String get temperatureString => '${temperature.toStringAsFixed(0)}°C';

  /// Format humidity as string with percentage
  String get humidityString => '$humidity%';

  /// Format wind speed as string
  String get windSpeedString => '${windSpeed.toStringAsFixed(1)} km/h';

  /// Format sunlight hours as string
  String get sunlightString {
    final hours = sunlightHours;
    if (hours == null) return 'N/A';
    return '${hours.toStringAsFixed(1)} hrs';
  }
}

