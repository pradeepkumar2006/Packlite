import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/weather_service.dart';
import '../core/data.dart';

class ExploreWeatherScreen extends StatefulWidget {
  final String? initialCity;
  const ExploreWeatherScreen({super.key, this.initialCity});

  @override
  State<ExploreWeatherScreen> createState() => _ExploreWeatherScreenState();
}

class _ExploreWeatherScreenState extends State<ExploreWeatherScreen> {
  late Future<WeatherData?> _weatherFuture;
  late String _currentCity;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _currentCity = widget.initialCity ?? 'Paris';
    _weatherFuture = WeatherService.fetchWeather(_currentCity).then((w) {
      if (w != null) _updateGlobalTripWeather(w);
      return w;
    });
  }

  void _searchCity(String city) {
    if (city.isEmpty) return;
    setState(() {
      _currentCity = city;
      _weatherFuture = WeatherService.fetchWeather(city).then((w) {
        if (w != null) _updateGlobalTripWeather(w);
        return w;
      });
      _isSearching = false;
    });
    _searchController.clear();
  }

  void _updateGlobalTripWeather(WeatherData w) {
    final t = TripData.lastActiveTrip;
    if (t != null) {
      final dest = t.destination.toLowerCase();
      final city = w.city.toLowerCase();
      
      // Match if destination contains city or city contains destination
      if (dest.contains(city) || city.contains(dest)) {
        final index = TripData.trips.indexWhere((trip) => trip.id == t.id);
        if (index != -1) {
          TripData.trips[index] = Trip(
            id: t.id, name: t.name, destination: t.destination, type: t.type,
            date: t.date, items: t.items, expenses: t.expenses, members: t.members,
            isCompleted: t.isCompleted, createdAt: t.createdAt, lastPackedAt: t.lastPackedAt,
            currencyCode: t.currencyCode, conversionRate: t.conversionRate,
            weatherIcon: _getEmojiForWeather(w.condition),
            temperature: '${w.temp.toInt()}°',
            toDoList: t.toDoList,
            bags: t.bags,
          );
        }
      }
    }
  }

  String _getEmojiForWeather(String cond) {
    String c = cond.toLowerCase();
    if (c.contains('sun') || c.contains('clear')) return '☀️';
    if (c.contains('cloud') || c.contains('overcast')) return '☁️';
    if (c.contains('rain') || c.contains('drizzle')) return '🌧️';
    if (c.contains('thunder') || c.contains('storm')) return '⛈️';
    if (c.contains('snow')) return '❄️';
    if (c.contains('fog') || c.contains('mist')) return '🌫️';
    return '🌥️';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search city...', border: InputBorder.none),
                onSubmitted: _searchCity,
              )
            : Text(_currentCity.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded, color: Colors.black),
            onPressed: () => setState(() => _isSearching = !_isSearching),
          ),
        ],
      ),
      body: FutureBuilder<WeatherData?>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          final w = snapshot.data;
          if (w == null) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('City not found.', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              TextButton(onPressed: () => _searchCity('Paris'), child: const Text('Reset to Paris', style: TextStyle(color: Colors.black))),
            ]));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const SizedBox(height: 48),
                _buildModernIcon(w.condition),
                const SizedBox(height: 32),
                Text('${w.temp.toInt()}°', style: const TextStyle(fontSize: 100, fontWeight: FontWeight.w500, letterSpacing: -5)),
                Text('So, it\'s ${w.condition}.', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const SizedBox(height: 48),
                
                // Packing Advice Section
                _buildPackingAdvice(w),
                
                const SizedBox(height: 40),
                
                // Stats Section
                _buildStats(w),
                
                const SizedBox(height: 64),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernIcon(String cond) {
    String c = cond.toLowerCase();
    IconData icon = Icons.cloud_outlined;
    if (c.contains('sun') || c.contains('clear')) icon = Icons.wb_sunny_outlined;
    if (c.contains('rain')) icon = Icons.cloud_outlined;
    if (c.contains('thunder') || c.contains('storm')) icon = Icons.bolt_rounded;
    if (c.contains('wind')) icon = Icons.air_rounded;

    return Icon(icon, size: 120, color: Colors.black);
  }

  Widget _buildPackingAdvice(WeatherData w) {
    final advice = _getPackingData(w);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PACKING ADVICE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: Colors.black38)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PackLiteTheme.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(advice.tip, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: advice.items.map((item) => _adviceItem(item.icon, item.name)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _adviceItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
      ],
    );
  }

  Widget _buildStats(WeatherData w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statItem('FEELS LIKE', '${w.feelsLike.toInt()}°'),
        _statItem('HUMIDITY', '72%'),
        _statItem('WIND', '14km/h'),
      ],
    );
  }

  Widget _statItem(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black38)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }

  PackingData _getPackingData(WeatherData w) {
    String cond = w.condition.toLowerCase();
    double temp = w.temp;

    if (cond.contains('rain')) {
      return PackingData(
        tip: "It's going to be wet. Keep yourself dry!",
        items: [
          AdviceItem(Icons.umbrella_rounded, 'Umbrella'),
          AdviceItem(Icons.dry_cleaning_rounded, 'Raincoat'),
          AdviceItem(Icons.water_drop_rounded, 'Waterproof'),
        ],
      );
    }

    if (temp > 25 || cond.contains('sun') || cond.contains('clear')) {
      return PackingData(
        tip: "Sun's out! Protect your skin and eyes.",
        items: [
          AdviceItem(Icons.wb_sunny_rounded, 'Sunscreen'),
          AdviceItem(Icons.visibility_rounded, 'Sunglasses'),
          AdviceItem(Icons.checkroom_rounded, 'Cotton wear'),
        ],
      );
    }

    if (temp < 15) {
      return PackingData(
        tip: "Chilly weather ahead. Stay warm!",
        items: [
          AdviceItem(Icons.dry_cleaning_rounded, 'Jacket'),
          AdviceItem(Icons.layers_rounded, 'Gloves'),
          AdviceItem(Icons.checkroom_rounded, 'Scarf'),
        ],
      );
    }

    return PackingData(
      tip: "Fair weather. Pack your usual essentials.",
      items: [
        AdviceItem(Icons.laptop_rounded, 'Gadgets'),
        AdviceItem(Icons.camera_alt_rounded, 'Camera'),
        AdviceItem(Icons.backpack_rounded, 'Backpack'),
      ],
    );
  }
}

class PackingData {
  final String tip;
  final List<AdviceItem> items;
  PackingData({required this.tip, required this.items});
}

class AdviceItem {
  final IconData icon;
  final String name;
  AdviceItem(this.icon, this.name);
}
