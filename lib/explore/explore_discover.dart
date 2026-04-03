import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/ai_service.dart';


class ExploreDiscoverScreen extends StatefulWidget {
  final String? initialCity;
  const ExploreDiscoverScreen({super.key, this.initialCity});

  @override
  State<ExploreDiscoverScreen> createState() => _ExploreDiscoverScreenState();
}

class _ExploreDiscoverScreenState extends State<ExploreDiscoverScreen> {
  late Future<Map<String, dynamic>> _discoveryFuture;
  late String _currentCity;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _currentCity = widget.initialCity ?? 'Manhattan';
    _discoveryFuture = AIService.getTravelInsights(_currentCity);

  }

  void _searchLocation(String location) {
    if (location.isEmpty) return;
    setState(() {
      _currentCity = location;
      _discoveryFuture = AIService.getTravelInsights(location);

      _isSearching = false;
    });
    _searchController.clear();
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                decoration: const InputDecoration(hintText: 'Where to, scout?', border: InputBorder.none, hintStyle: TextStyle(color: PackLiteTheme.mutedText)),
                onSubmitted: _searchLocation,
              )
            : Text(_currentCity.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2.5)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded, color: Colors.black),
            onPressed: () => setState(() => _isSearching = !_isSearching),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _discoveryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 1.5));
          }

          if (snapshot.hasError) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline_rounded, size: 40, color: PackLiteTheme.error),
              const SizedBox(height: 16),
              const Text('Could not discover.', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Tappable(onTap: () => _searchLocation('Manhattan'), child: const Text('RESET TO MANHATTAN', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w900))),
            ]));
          }

          final data = snapshot.data!;
          final places = (data['places'] as List?) ?? [];
          final food = (data['restaurants'] as List?) ?? [];
          final hotels = (data['hotels'] as List?) ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _buildHeaderSection(),
                const SizedBox(height: 48),
                _buildCategorySection('TOP VISITING PLACES', places, Icons.map_outlined),
                const SizedBox(height: 48),
                _buildCategorySection('MUST-TRY FOOD', food, Icons.restaurant_menu_rounded),
                const SizedBox(height: 48),
                _buildCategorySection('BEST STAYS', hotels, Icons.bed_rounded),
                const SizedBox(height: 64),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI DISCOVERY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: Colors.black38)),
        const SizedBox(height: 8),
        Text('Curating the vibe of $_currentCity.', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1.5, height: 1.1)),
        const SizedBox(height: 16),
        Container(
          height: 3, width: 40, decoration: const BoxDecoration(color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildCategorySection(String title, List items, IconData icon) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.black38),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Colors.black38)),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildDiscoveryCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryCard(Map item) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PackLiteTheme.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PackLiteTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item['name']?.toString() ?? '...', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Text(item['vibe']?.toString().toUpperCase() ?? 'SMART', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1.2)),
              ),
            ],
          ),
          const Spacer(),
          Text(item['reason']?.toString() ?? 'Fetching insights...', style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          const Row(
            children: [
              Text('EXPLORE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1, decoration: TextDecoration.underline)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }
}
