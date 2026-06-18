import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double tempC;
  final double humidity;
  final double windKph;
  final double rainMm;
  final String condition;
  final String icon;
  final List<WeatherDay> forecast;

  WeatherData({
    required this.tempC,
    required this.humidity,
    required this.windKph,
    required this.rainMm,
    required this.condition,
    required this.icon,
    required this.forecast,
  });
}

class WeatherDay {
  final String day;
  final double maxC;
  final double minC;
  final double rainMm;
  final String icon;
  final String condition;

  WeatherDay({
    required this.day,
    required this.maxC,
    required this.minC,
    required this.rainMm,
    required this.icon,
    required this.condition,
  });
}

class WeatherService {
  // Open-Meteo — completely free, no API key, accurate for Uganda
  // Lat/Lng = Kampala, Uganda
  static const double _lat = 0.3476;
  static const double _lng = 32.5825;

  static String _icon(int wmo) {
    if (wmo == 0) return '☀️';
    if (wmo <= 2) return '⛅';
    if (wmo <= 3) return '☁️';
    if (wmo <= 49) return '🌫️';
    if (wmo <= 59) return '🌦️';
    if (wmo <= 69) return '🌧️';
    if (wmo <= 79) return '🌨️';
    if (wmo <= 82) return '🌧️';
    if (wmo <= 99) return '⛈️';
    return '🌤️';
  }

  static String _condition(int wmo) {
    if (wmo == 0) return 'Clear Sky';
    if (wmo <= 2) return 'Partly Cloudy';
    if (wmo <= 3) return 'Overcast';
    if (wmo <= 49) return 'Foggy';
    if (wmo <= 59) return 'Light Drizzle';
    if (wmo <= 69) return 'Rain';
    if (wmo <= 79) return 'Snow';
    if (wmo <= 82) return 'Heavy Rain';
    if (wmo <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static Future<WeatherData> fetchWeather() async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$_lat&longitude=$_lng'
      '&current=temperature_2m,relative_humidity_2m,wind_speed_10m,'
      'precipitation,weather_code'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum'
      '&timezone=Africa%2FKampala'
      '&forecast_days=7',
    );

    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Weather fetch failed');

    final j = json.decode(res.body) as Map<String, dynamic>;
    final curr = j['current'] as Map<String, dynamic>;
    final daily = j['daily'] as Map<String, dynamic>;

    final wmo = (curr['weather_code'] as num).toInt();
    final today = DateTime.now();

    final forecast = <WeatherDay>[];
    final dates = daily['time'] as List;
    for (int i = 1; i < dates.length && i <= 6; i++) {
      final d = DateTime.tryParse(dates[i].toString()) ?? today.add(Duration(days: i));
      final code = (daily['weather_code'] as List)[i] as num;
      forecast.add(WeatherDay(
        day: _days[d.weekday - 1],
        maxC: ((daily['temperature_2m_max'] as List)[i] as num).toDouble(),
        minC: ((daily['temperature_2m_min'] as List)[i] as num).toDouble(),
        rainMm: ((daily['precipitation_sum'] as List)[i] as num).toDouble(),
        icon: _icon(code.toInt()),
        condition: _condition(code.toInt()),
      ));
    }

    return WeatherData(
      tempC: (curr['temperature_2m'] as num).toDouble(),
      humidity: (curr['relative_humidity_2m'] as num).toDouble(),
      windKph: (curr['wind_speed_10m'] as num).toDouble(),
      rainMm: (curr['precipitation'] as num).toDouble(),
      condition: _condition(wmo),
      icon: _icon(wmo),
      forecast: forecast,
    );
  }
}
