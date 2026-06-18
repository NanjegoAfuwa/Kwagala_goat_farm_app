import 'package:flutter/material.dart';
import '../Widgets/shimmer.dart';
import '../Services/weather_service.dart';
import '../theme_helper.dart';
import '../Widgets/hover_card.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);
  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData? _weather;
  bool _loading = true;
  String? _error;

  static const Color _green = Color(0xFF2E7D32);
  static const Color _orange = Color(0xFFF57C00);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final w = await WeatherService.fetchWeather();
      if (mounted) setState(() { _weather = w; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  // Farm advisory based on weather conditions
  List<Map<String, String>> _advisories(WeatherData w) {
    final list = <Map<String, String>>[];
    if (w.rainMm > 10) {
      list.add({'icon': '🏚️', 'color': 'red', 'tip': 'Move goats to shelter — heavy rain expected.'});
    } else if (w.rainMm > 2) {
      list.add({'icon': '☔', 'color': 'orange', 'tip': 'Light rain — secure paddock shelter flaps.'});
    }
    if (w.tempC > 30) {
      list.add({'icon': '🌡️', 'color': 'red', 'tip': 'High heat — ensure goats have shade and water.'});
    } else if (w.tempC < 16) {
      list.add({'icon': '🧥', 'color': 'blue', 'tip': 'Cool temperatures — check young kids for warmth.'});
    }
    if (w.windKph > 30) {
      list.add({'icon': '💨', 'color': 'orange', 'tip': 'Strong winds — check fence lines and enclosures.'});
    }
    if (w.humidity > 85) {
      list.add({'icon': '💧', 'color': 'orange', 'tip': 'High humidity — monitor for respiratory issues.'});
    }
    if (list.isEmpty) {
      list.add({'icon': '✅', 'color': 'green', 'tip': 'Good conditions for outdoor grazing today.'});
      list.add({'icon': '🌿', 'color': 'green', 'tip': 'Ideal weather for feeding and health checks.'});
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: const Text('Weather & Farm Advisory',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
        ], // Fixed: Removed the floating stray comma from right below this line
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            color: const Color(0xFFF57C00),
            height: 3,
          ),
        ),
      ),
      body: _loading
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Shimmer(height: 130, borderRadius: BorderRadius.circular(16)),
                  const SizedBox(height: 16),
                  Shimmer(height: 90, borderRadius: BorderRadius.circular(16)),
                  const SizedBox(height: 16),
                  Shimmer(height: 160, borderRadius: BorderRadius.circular(16)),
                ],
              ),
            )
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: _green,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HoverCard(child: _currentWeatherCard()),
                        const SizedBox(height: 16),
                        HoverCard(child: _advisoryCard()),
                        const SizedBox(height: 16),
                        HoverCard(child: _forecastCard()),
                        const SizedBox(height: 16),
                        _statsRow(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: AppTheme.textMid(context)),
          const SizedBox(height: 16),
          Text('Could not load weather.\n$_error',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMid(context), fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            onPressed: _load,
          ),
        ]),
      );

  Widget _currentWeatherCard() {
    final w = _weather!;
    final isRainy = w.rainMm > 2;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isRainy
              ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
              : [_green, const Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: (isRainy ? Colors.blue : Colors.green).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Kampala, Uganda',
                  style: TextStyle(color: Colors.white70, fontSize: 13,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('Live Conditions',
                  style: TextStyle(color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ]),
            Text(w.icon, style: const TextStyle(fontSize: 56)),
          ]),
          const SizedBox(height: 20),
          Text('${w.tempC.toStringAsFixed(1)}°C',
              style: const TextStyle(color: Colors.white, fontSize: 52,
                  fontWeight: FontWeight.w800, height: 1)),
          const SizedBox(height: 6),
          Text(w.condition,
              style: const TextStyle(color: Colors.white70, fontSize: 16,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _statsRow() {
    final w = _weather!;
    return Row(children: [
      _statTile('💧', 'Humidity', '${w.humidity.toStringAsFixed(0)}%'),
      const SizedBox(width: 12),
      _statTile('💨', 'Wind', '${w.windKph.toStringAsFixed(0)} km/h'),
      const SizedBox(width: 12),
      _statTile('🌧️', 'Rain', '${w.rainMm.toStringAsFixed(1)} mm'),
    ]);
  }

  Widget _statTile(String icon, String label, String val) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: AppTheme.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border(context))),
          child: Column(children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(val, style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: AppTheme.textDark(context))),
            Text(label, style: TextStyle(
                fontSize: 10, color: AppTheme.textMid(context))),
          ]),
        ),
      );

  Widget _advisoryCard() {
    final advisories = _advisories(_weather!);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF57C00), size: 18),
            const SizedBox(width: 8),
            Text('Farm Advisory',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                    color: AppTheme.textDark(context))),
          ]),
          const SizedBox(height: 12),
          ...advisories.map((a) {
            Color bg, fg;
            if (a['color'] == 'red') { bg = const Color(0xFFFEF2F2); fg = const Color(0xFFDC2626); }
            else if (a['color'] == 'orange') { bg = const Color(0xFFFFF7ED); fg = const Color(0xFFF57C00); }
            else if (a['color'] == 'blue') { bg = const Color(0xFFEFF6FF); fg = const Color(0xFF1D4ED8); }
            else { bg = const Color(0xFFDCFCE7); fg = const Color(0xFF15803D); }
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: fg.withOpacity(0.2))),
              child: Row(children: [
                Text(a['icon']!, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(a['tip']!,
                    style: TextStyle(fontSize: 13, color: fg,
                        fontWeight: FontWeight.w500))),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _forecastCard() {
    final forecast = _weather!.forecast;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border(context))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('6-Day Forecast',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                  color: AppTheme.textDark(context))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: forecast.map((d) => Expanded(
              child: Column(children: [
                Text(d.day, style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.bold,
                    color: AppTheme.textMid(context))),
                const SizedBox(height: 6),
                Text(d.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text('${d.maxC.toStringAsFixed(0)}°',
                    style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.bold, color: AppTheme.textDark(context))),
                Text('${d.minC.toStringAsFixed(0)}°',
                    style: TextStyle(fontSize: 11,
                        color: AppTheme.textLight(context))),
                if (d.rainMm > 1) ...[
                  const SizedBox(height: 3),
                  Text('${d.rainMm.toStringAsFixed(0)}mm',
                      style: TextStyle(fontSize: 9,
                          color: AppTheme.textDark(context), fontWeight: FontWeight.w600)),
                ],
              ]),
            )).toList(),
          ),
        ],
      ),
    );
  }
}