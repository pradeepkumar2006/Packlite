import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/data.dart';
import '../trip/trip_readiness_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final u = TripData.user;
    final activeTrip = TripData.lastActiveTrip;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context, u, activeTrip),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _buildExectiveStats(u),
                  const SizedBox(height: 48),
                  
                  // NEW USEFUL SECTIONS
                  _buildSectionHeader('Plan Ahead'),
                  const SizedBox(height: 16),
                  _buildUpcomingJourney(activeTrip, context),
                  const SizedBox(height: 20),
                  _buildAIRecommendation(activeTrip),
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('Essential Checklist'),
                  const SizedBox(height: 16),
                  _buildEssentialChecklist(),
                  const SizedBox(height: 48),
                  
                  _buildSectionHeader('Trip Collections'),
                  const SizedBox(height: 16),
                  _buildTripCollections(context),
                  const SizedBox(height: 48),

                  _buildSectionHeader('Bag Command Center'),
                  const SizedBox(height: 16),
                  _buildBagCommandCenter(activeTrip),
                  const SizedBox(height: 48),

                  _buildLogoutButton(),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TravelerProfile? u, Trip? active) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: active?.progress ?? 0.0,
                      strokeWidth: 4,
                      backgroundColor: PackLiteTheme.background,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    width: 86,
                    height: 86,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                    child: u?.photoUrl != null 
                      ? Image.network(u!.photoUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.person_rounded, size: 40, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                u?.name ?? 'Traveler',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_rounded, size: 14, color: Colors.blue.shade400),
                  const SizedBox(width: 4),
                  Text(
                    '${u?.travelStyle ?? 'Explorer'} • ${u?.homeCity ?? 'Global'}',
                    style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExectiveStats(TravelerProfile? u) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildStatCard('Footprints', '${u?.milesCovered ?? 0}', 'KM TRAVELED'),
          const SizedBox(width: 16),
          _buildStatCard('Efficiency', '92%', 'PACK SCORE'),
          const SizedBox(width: 16),
          _buildStatCard('Trips', '${TripData.trips.length}', 'COLLECTION'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String sub) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PackLiteTheme.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PackLiteTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sub, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1.5, color: Colors.black38)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildUpcomingJourney(Trip? t, BuildContext context) {
    final hasTrip = t != null;
    final countdown = hasTrip ? t.date.difference(DateTime.now()).inDays : 0;

    return Material(
      color: Colors.black,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          PackLiteTheme.haptic();
          if (hasTrip) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => TripReadinessScreen(trip: t)),
            );
          } else {
            // Logic to start a new trip or show a placeholder
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Starting new adventure...')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PLANNING AHEAD', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    Text(
                      hasTrip ? t.destination : 'Ready for a new adventure?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasTrip 
                        ? 'Departs in $countdown days • ${t.temperature ?? "24°C"}'
                        : 'Tap here to create your next packing list.', 
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIRecommendation(Trip? t) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFECB3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              t == null 
                ? 'Planning a trip? Ask PackLite for tailored checklists!'
                : 'Since you are heading to ${t.destination}, consider packing a high-capacity power bank and a universal adapter.',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.brown, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEssentialChecklist() {
    final essentials = [
      {'icon': Icons.airplane_ticket_outlined, 'label': 'Passport'},
      {'icon': Icons.electrical_services_outlined, 'label': 'Adapters'},
      {'icon': Icons.medical_services_outlined, 'label': 'First Aid'},
      {'icon': Icons.credit_card_outlined, 'label': 'Travel Card'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: essentials.map((e) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PackLiteTheme.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(e['icon'] as IconData, size: 16, color: Colors.black54),
            const SizedBox(width: 10),
            Text(e['label'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(width: 8),
            const Icon(Icons.check_circle_outline, size: 14, color: Colors.black26),
          ],
        ),
      )).toList(),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2, color: Colors.black38),
    );
  }


  Widget _buildTripCollections(BuildContext context) {
    final trips = TripData.trips;
    if (trips.isEmpty) return const SizedBox.shrink();

    return Column(
      children: trips.map((t) => Tappable(
        onTap: () {
          // Navigate to trip detail logic
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: PackLiteTheme.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: t.isCompleted ? Colors.black12 : Colors.black, borderRadius: BorderRadius.circular(12)),
                child: Icon(t.isCompleted ? Icons.history_rounded : Icons.flight_takeoff_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.destination, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text(t.isCompleted ? 'Completed Trip' : 'Active Journey', style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black12),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildBagCommandCenter(Trip? trip) {
    if (trip == null) return const SizedBox.shrink();

    return Column(
      children: trip.bags.map((bag) {
        final bagItems = trip.items.where((i) => i.bagId == bag.id).toList();
        final weight = bagItems.fold(0.0, (sum, i) => sum + (i.weight ?? 0.0)) / 1000;
        final packed = bagItems.where((i) => i.isPacked).length;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PackLiteTheme.background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: PackLiteTheme.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(bag.type == 'Backpack' ? Icons.backpack_rounded : Icons.luggage_rounded, size: 20, color: Colors.black),
                  const SizedBox(width: 12),
                  Text(bag.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const Spacer(),
                  Text('${weight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: bagItems.isEmpty ? 0 : packed / bagItems.length,
                  minHeight: 6,
                  backgroundColor: Colors.black.withOpacity(0.05),
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLogoutButton() {
    return Tappable(
      onTap: () => PackLiteTheme.haptic(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: const Center(
          child: Text(
            'DEACTIVATE SESSION',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
          ),
        ),
      ),
    );
  }
}
