import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/data.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activeTrip = TripData.lastActiveTrip;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Trip Roadmap', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.sync_rounded, color: Colors.black),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: activeTrip == null 
        ? _buildEmptyState() 
        : _buildTimeline(activeTrip),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_rounded, size: 80, color: PackLiteTheme.cardBorder),
          const SizedBox(height: 24),
          const Text('No active roadmap', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 8),
          Text('Plan a trip to see your timeline here.', style: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTimeline(Trip t) {
    // Mock data for the Premium Itinerary
    final events = [
      _TripEvent(
        time: '09:00 AM',
        title: 'Flight to ${t.destination}',
        subtitle: 'Indigo 402 • Terminal 2, Gate B12',
        icon: Icons.flight_takeoff_rounded,
        type: 'flight',
        status: 'On Time',
      ),
      _TripEvent(
        time: '12:30 PM',
        title: 'Airport Pickup',
        subtitle: 'Uber Premium • Meeting Point A',
        icon: Icons.local_taxi_rounded,
        type: 'transport',
      ),
      _TripEvent(
        time: '01:30 PM',
        title: 'Check-in: Grand Plaza',
        subtitle: 'Booking ID: #PL8829 | Late check-in avail.',
        icon: Icons.hotel_rounded,
        type: 'hotel',
      ),
      _TripEvent(
        time: '04:00 PM',
        title: 'Explore: City Center',
        subtitle: 'Suggested: Walk through the historic district.',
        icon: Icons.explore_outlined,
        type: 'activity',
      ),
      _TripEvent(
        time: '08:00 PM',
        title: 'Dinner at Panorama',
        subtitle: 'Table reserved for 2',
        icon: Icons.restaurant_rounded,
        type: 'food',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI TRIP MANAGER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text('Syncing with your tickets...', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ...List.generate(events.length, (index) {
          final e = events[index];
          final isLast = index == events.length - 1;
          return _buildEventItem(e, isLast);
        }),
      ],
    );
  }

  Widget _buildEventItem(_TripEvent e, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: e.type == 'flight' ? Colors.black : PackLiteTheme.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PackLiteTheme.cardBorder),
                ),
                child: Icon(e.icon, color: e.type == 'flight' ? Colors.white : Colors.black, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: PackLiteTheme.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.time, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black38)),
                    if (e.status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(e.status!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 10)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(e.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(e.subtitle, style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripEvent {
  final String time;
  final String title;
  final String subtitle;
  final IconData icon;
  final String type;
  final String? status;

  _TripEvent({required this.time, required this.title, required this.subtitle, required this.icon, required this.type, this.status});
}
