import 'package:flutter/material.dart';
import '../trip/solo_trip.dart';
import '../trip/group_trip.dart';
import '../trip/solo_setup.dart';
import '../trip/group_setup.dart';
import '../core/theme.dart';
import '../core/data.dart';
import '../explore/explore_discover.dart';
import '../core/ai_service.dart';
import '../core/amazon_utils.dart';

import '../core/weather_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'profile_screen.dart';
import 'itinerary_screen.dart';
import 'profile_setup_screen.dart';
import '../core/currency_service.dart';
import 'ai_concierge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  double _liveRate = 82.5; // Default for fallback
  bool _isLiveLoading = false;

  @override
  void initState() {
    super.initState();
    _initUser();
    _fetchTripWeather();
    _fetchLiveCurrency();
  }

  void _fetchLiveCurrency() async {
    setState(() => _isLiveLoading = true);
    final rate = await CurrencyService.getExchangeRate('USD', 'INR');
    if (mounted) {
      setState(() {
        _liveRate = rate;
        _isLiveLoading = false;
      });
    }
  }

  void _initUser() {
    final cur = auth.FirebaseAuth.instance.currentUser;
    if (cur != null) {
      if (TripData.user == null) {
        TripData.user = TravelerProfile(
          name: cur.displayName ?? 'Traveler',
          email: cur.email,
          photoUrl: cur.photoURL,
        );
      }

      // If home city is not set, show the setup sheet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (TripData.user?.homeCity == null) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                ProfileSetupScreen(onComplete: () => setState(() {})),
          );
        }
      });
    }
  }

  void _fetchTripWeather() async {
    final t = TripData.lastActiveTrip;
    if (t != null) {
      final w = await WeatherService.fetchWeather(t.destination);
      if (w != null) {
        setState(() {
          final index = TripData.trips.indexWhere((trip) => trip.id == t.id);
          if (index != -1) {
            TripData.trips[index] = Trip(
              id: t.id,
              name: t.name,
              destination: t.destination,
              type: t.type,
              date: t.date,
              items: t.items,
              expenses: t.expenses,
              members: t.members,
              isCompleted: t.isCompleted,
              createdAt: t.createdAt,
              lastPackedAt: t.lastPackedAt,
              currencyCode: t.currencyCode,
              conversionRate: t.conversionRate,
              weatherIcon: _getIconForWeather(w.condition),
              temperature: '${w.temp.toInt()}°',
              toDoList: t.toDoList,
              bags: t.bags,
            );
          }
        });
      }
    }
  }

  String _getIconForWeather(String cond) {
    String c = cond.toLowerCase();
    if (c.contains('sun') || c.contains('clear')) return '☀️';
    if (c.contains('cloud') || c.contains('overcast')) return '☁️';
    if (c.contains('rain') || c.contains('drizzle')) return '🌧️';
    if (c.contains('thunder') || c.contains('storm')) return '⛈️';
    if (c.contains('snow')) return '❄️';
    return '🌥️';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildPage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: PackLiteTheme.cardBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) {
            setState(() => _currentIndex = i);
            if (i == 0) _fetchTripWeather();
          },
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black38,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_rounded),
              label: 'Prep',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.security_rounded),
              label: 'Command',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              label: 'Itinerary',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentIndex) {
      case 1:
        return _buildPrepTab();
      case 2:
        return _buildGlobalCommandHub();
      case 3:
        return const ItineraryScreen();
      default:
        return _buildHome();
    }
  }

  Widget _buildPrepTab() {
    final t = TripData.lastActiveTrip;
    if (t == null) return _buildEmptyPrep();

    final shoppingItems = t.items.where((i) => i.needsToBuy).toList();
    final pendingTasks = t.toDoList.where((task) => !task.isDone).toList();
    final progress = t.progress;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          pinned: true,
          elevation: 0,
          title: const Text(
            'PREPARATION',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -1,
            ),
          ),
          surfaceTintColor: Colors.transparent,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrepHeader(t),
                const SizedBox(height: 24),
                _buildAIConciergeCard(t),
                const SizedBox(height: 32),
                _buildPrepProgressSection(progress),
                const SizedBox(height: 32),

                if (pendingTasks.isNotEmpty) ...[
                  _sectionHeader(
                    'TRIP CHECKLIST',
                    '${pendingTasks.length} PENDING',
                  ),
                  const SizedBox(height: 16),
                  ...pendingTasks
                      .take(3)
                      .map((task) => _taskTile(task))
                      .toList(),
                  if (pendingTasks.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${pendingTasks.length - 3} more tasks',
                        style: const TextStyle(
                          color: Colors.black26,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],

                if (shoppingItems.isNotEmpty) ...[
                  _sectionHeader(
                    'SHOPPING LIST',
                    '${shoppingItems.length} ITEMS',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: shoppingItems.length,
                      itemBuilder: (context, i) {
                        final item = shoppingItems[i];
                        return Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F6F2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.shopping_bag_outlined, size: 20),
                              const Spacer(),
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Tappable(
                                onTap: () => _launchAmazon(item.name),
                                child: const Text(
                                  'GET ON AMAZON',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 8,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrepHeader(Trip t) {
    final daysLeft = t.date.difference(DateTime.now()).inDays;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.destination.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$daysLeft DAYS LEFT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Your next journey\nis calling.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrepProgressSection(double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F2),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black.withOpacity(0.05),
                  color: Colors.black,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PACKING STATUS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    color: Colors.black38,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You are almost ready!\nJust a few more things.',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            color: Colors.black38,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 9,
            color: Colors.black26,
          ),
        ),
      ],
    );
  }

  Widget _taskTile(ToDoItem task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PackLiteTheme.cardBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.radio_button_off_rounded, color: Colors.black12, size: 20),
          const SizedBox(width: 16),
          Text(
            task.title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPrep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.checklist_rounded,
            size: 80,
            color: Color(0xFFF1F1ED),
          ),
          const SizedBox(height: 24),
          const Text(
            'NOTHING TO PREP',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Plan a legacy voyage to start prepping.',
            style: TextStyle(
              color: PackLiteTheme.mutedText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _launchAmazon(String query) async {
    await AmazonUtils.launch(query);
  }

  Widget _buildHome() {
    final activeTrip = TripData.lastActiveTrip;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleSpacing: 24,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.luggage_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'PACKLITE',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.black,
                size: 24,
              ),
            ),
            IconButton(
              onPressed: () => _showBagCommandSheet(context),
              icon: Stack(
                alignment: Alignment.topRight,
                children: [
                  const Icon(
                    Icons.luggage_outlined,
                    color: Colors.black,
                    size: 24,
                  ),
                  if (activeTrip != null && activeTrip.progress < 1.0)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
            Tappable(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => const ProfileScreen()),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(right: 24, left: 8),
                width: 32,
                height: 32,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: PackLiteTheme.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: PackLiteTheme.cardBorder),
                ),
                child: TripData.user?.photoUrl != null
                    ? Image.network(TripData.user!.photoUrl!, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${TripData.user?.name?.split(' ').first ?? 'Traveler'}!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'Ready for your next adventure?',
                  style: TextStyle(
                    color: PackLiteTheme.mutedText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'PLAN NEW TRIP',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    color: Colors.black38,
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickAction(
                  'Solo Journey',
                  'For personal travel goals',
                  Icons.person_outline_rounded,
                  true,
                ),
                const SizedBox(height: 12),
                _buildQuickAction(
                  'Group Getaway',
                  'Best with friends & family',
                  Icons.group_outlined,
                  false,
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ONGOING TRIP',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: Colors.black,
                      ),
                    ),
                    if (activeTrip != null)
                      TextButton(
                        onPressed: () => setState(() => _currentIndex = 1),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (activeTrip == null)
                  _buildEmptyState()
                else ...[
                  _buildOngoingTripCard(activeTrip),
                  const SizedBox(height: 24),
                  _buildPriorityPrep(activeTrip),
                ],
                const SizedBox(height: 32),
                if (activeTrip != null)
                  _buildDiscoveryPreview(activeTrip.destination),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildOngoingTripCard(Trip t) {
    final packedCount = t.items.where((i) => i.isPacked).length;
    final totalCount = t.items.length;
    final progress = t.progress;

    return Tappable(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => t.type == 'Solo'
                ? SoloTripScreen(trip: t)
                : GroupTripScreen(trip: t),
          ),
        );
        if (result == true) {
          setState(() {});
          _fetchTripWeather();
        }
      },
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Dynamic Parallax Destination Text (Concept)
            Positioned(
              right: -20,
              bottom: -24,
              child: Opacity(
                opacity: 0.05,
                child: Text(
                  t.destination.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -5,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                // Trip Info Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              t.type.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Tappable(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => ExploreDiscoverScreen(
                                  initialCity: t.destination,
                                ),
                              ),
                            ),
                            child: Text(
                              t.destination,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Text(
                            t.name,
                            style: TextStyle(
                              color: PackLiteTheme.mutedText,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onLongPress: () {
                          PackLiteTheme.haptic();
                          // Simulated pulse
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: PackLiteTheme.cardBorder),
                          ),
                          child: Center(
                            child: Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // MORPHING AREA
                if (progress == 0)
                  _buildPhase1UI()
                else if (progress < 1)
                  _buildPhase2UI(t)
                else
                  _buildPhase3UI(t),

                const SizedBox(height: 20),

                // Footer Info
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Tappable(
                        onTap: () => _showVault(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.airplane_ticket_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'VIEW TICKET',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.checklist_rounded,
                        size: 16,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$packedCount/$totalCount items',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhase1UI() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FORGET-ME-NOT',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 1,
              color: Colors.black38,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _quickAddBadge('🔌 Universal Adapter'),
                _quickAddBadge('📄 Insurance'),
                _quickAddBadge('💊 First Aid'),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _quickAddBadge(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: PackLiteTheme.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
      ),
    );
  }

  Widget _buildPhase2UI(Trip t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WEIGHT EST.',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1,
                      color: Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '⚖️ ${t.packedWeightKg.toStringAsFixed(1)}kg / ${t.totalWeightKg.toStringAsFixed(1)}kg',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'CATEGORY HEALTH',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1,
                      color: Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _dot(Colors.black),
                      _dot(Colors.black),
                      _dot(Colors.black12),
                      _dot(Colors.black12),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
    width: 6,
    height: 6,
    margin: const EdgeInsets.only(left: 4),
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );

  Widget _buildPhase3UI(Trip t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoBit(
                  'LOCAL TIME',
                  '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                  Icons.access_time_rounded,
                ),
                _buildDivider(),
                _buildInfoBit(
                  'WEATHER',
                  '${t.temperature ?? "--°"} ${t.weatherIcon ?? "☀️"}',
                  Icons.wb_sunny_outlined,
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.white10,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Colors.amber,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getTripInsight(t),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTripInsight(Trip t) {
    if (t.expenses.isNotEmpty) {
      return 'Budget track: \$${t.totalSpent.toStringAsFixed(0)} spent so far.';
    }
    final tempStr = t.temperature?.replaceAll('°', '') ?? '';
    final temp = double.tryParse(tempStr) ?? 20.0;

    if (temp >= 18 && temp <= 25) {
      return 'Forecast says mild! Perfect for exploring.';
    } else if (temp > 25) {
      return 'It\'s quite warm! Stay hydrated and pack light.';
    } else if (temp < 18) {
      return 'Forecast says it\'s a bit chilly! Wear layers.';
    }

    final rem = t.items.length - t.items.where((i) => i.isPacked).length;
    return t.progress == 1.0
        ? 'All set! Every single item is in your suitcase.'
        : 'Keep going! $rem items still to pack.';
  }

  Widget _buildInfoBit(String sub, String main, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(height: 6),
        Text(
          sub,
          style: const TextStyle(
            color: Colors.white38,
            fontWeight: FontWeight.w900,
            fontSize: 8,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          main,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 30, color: Colors.white10);

  Widget _buildNearMeItem(IconData icon, String label) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PackLiteTheme.cardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.black87),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
          ),
        ],
      ),
    );
  }


  Widget _buildQuickAction(
    String title,
    String desc,
    IconData icon,
    bool isSolo,
  ) {
    return Tappable(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) =>
                isSolo ? const SoloSetupScreen() : const GroupSetupScreen(),
          ),
        );
        if (result == true) {
          setState(() {});
          _fetchTripWeather();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSolo ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSolo
              ? null
              : Border.all(color: PackLiteTheme.cardBorder, width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isSolo
                  ? Colors.white24
                  : PackLiteTheme.background,
              child: Icon(
                icon,
                color: isSolo ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSolo ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      color: isSolo ? Colors.white60 : PackLiteTheme.mutedText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isSolo ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDiscoveryPreview(String city) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AI DISCOVERY: ${city.toUpperCase()}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.5,
                color: Colors.black,
              ),
            ),
            Tappable(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => ExploreDiscoverScreen(initialCity: city),
                ),
              ),
              child: const Text(
                'Explore All',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, dynamic>>(
          future: AIService.getTravelInsights(city),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: PackLiteTheme.background,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black12,
                    ),
                  ),
                ),
              );
            }
            if (snapshot.hasError || snapshot.data == null)
              return const SizedBox.shrink();

            final places = (snapshot.data!['places'] as List?) ?? [];
            if (places.isEmpty) return const SizedBox.shrink();

            return SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: places.length > 3 ? 3 : places.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final p = places[index];
                  return Tappable(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) =>
                            ExploreDiscoverScreen(initialCity: city),
                      ),
                    ),
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: PackLiteTheme.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: PackLiteTheme.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name']?.toString() ?? '...',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            p['vibe']?.toString().toUpperCase() ?? 'SPOT',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 8,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: PackLiteTheme.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.luggage_outlined, size: 48, color: Colors.black12),
          const SizedBox(height: 16),
          Text(
            'No ongoing trip',
            style: TextStyle(
              color: PackLiteTheme.mutedText,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your active journey will appear here.',
            style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityPrep(Trip t) {
    final pending = t.toDoList.where((task) => !task.isDone).toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRIORITY PREP',
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          ...pending
              .take(2)
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle_outlined,
                        color: Colors.white24,
                        size: 16,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 8),
          Tappable(
            onTap: () => setState(() => _currentIndex = 1),
            child: const Text(
              'VIEW ALL PREP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGlobalCommandHub() {
    final trip = TripData.lastActiveTrip;
    final u = TripData.user;
    final dest = trip?.destination ?? 'your destination';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          pinned: true,
          elevation: 0,
          title: Text(
            'COMMAND: ${dest.toUpperCase()}',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shield_rounded, color: Colors.black),
            ),
            const SizedBox(width: 8),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. LIVE CURRENCY INTELLIGENCE
                _sectionHeader('CURRENCY IQ', 'LIVE'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_graph_rounded,
                            color: Colors.white38,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'FLEXIBLE EXCHANGE: USD - INR',
                            style: TextStyle(
                              color: Colors.white30,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$1.00',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                ),
                              ),
                              Text(
                                'BASE UNIT',
                                style: TextStyle(
                                  color: Colors.white24,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          _isLiveLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.blueAccent,
                                  ),
                                )
                              : const Icon(
                                  Icons.compare_arrows_rounded,
                                  color: Colors.white24,
                                ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${_liveRate.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.blue.shade200,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                ),
                              ),
                              const Text(
                                'LOCAL VALUE',
                                style: TextStyle(
                                  color: Colors.white24,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. EMERGENCY SOS (ONE TAP SAFETY)
                _sectionHeader('SECURITY TERMINAL', 'SOS'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.local_police_rounded,
                              color: Colors.red,
                              size: 24,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'POLICE',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                color: Colors.red,
                              ),
                            ),
                            Text(
                              '100 / 112',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.medical_services_rounded,
                              color: Colors.blue,
                              size: 24,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'MEDICAL',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              '102 / 108',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 3. LOCAL "NEAR ME" AI
                _sectionHeader('DESTINATION INTEL', 'NEAR ME'),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildNearMeItem(
                        Icons.local_hospital_rounded,
                        'Hospitals',
                      ),
                      _buildNearMeItem(Icons.atm_rounded, 'ATMs'),
                      _buildNearMeItem(
                        Icons.account_balance_rounded,
                        'Embassy',
                      ),
                      _buildNearMeItem(
                        Icons.local_pharmacy_rounded,
                        'Pharmacy',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 4. LANGUAGE PHRASE-VAULT
                _sectionHeader('LANGUAGE PROTOCOL', 'PHRASES'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: PackLiteTheme.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: PackLiteTheme.cardBorder),
                  ),
                  child: Column(
                    children: [
                      _buildPhraseItem(
                        'Emergency Help',
                        'Kyu-kyusha o yonde kudasai!',
                      ),
                      const Divider(height: 32),
                      _buildPhraseItem(
                        'Nearest Hospital',
                        'Ichiban chikai byoin wa doko?',
                      ),
                      const Divider(height: 32),
                      _buildPhraseItem(
                        'Where is the ATM?',
                        'ATM wa doko desu ka?',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 5. DIGITAL DOCUMENT LOCKER
                _sectionHeader('SECURE ASSETS', 'DOCUMENTS'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: PackLiteTheme.cardBorder,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDocItem(
                        Icons.badge_rounded,
                        'Passport Number',
                        u?.passportNumber ?? 'EX82937XX',
                        true,
                      ),
                      const SizedBox(height: 16),
                      _buildDocItem(
                        Icons.airplane_ticket_rounded,
                        'E-Visa Status',
                        'APPROVED',
                        true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhraseItem(String label, String phrase) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                phrase,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.volume_up_rounded, size: 20),
        ),
      ],
    );
  }

  void _showVault(BuildContext context) {
    // Obsolete, Vault is now a tab
  }

  Widget _buildDocItem(IconData icon, String title, String name, bool isV) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: PackLiteTheme.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: Colors.black54),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  color: isV ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (isV)
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
      ],
    );
  }

  Widget _buildAIConciergeCard(Trip t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4FE),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AI CONCIERGE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const Text(
                'READY',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Need travel advice?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ask me about ${t.destination}, packing tips, or local secrets.',
            style: const TextStyle(
              color: Colors.black45,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          Tappable(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AIConciergeSheet(),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Start Consultation',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBagCommandSheet(BuildContext context) {
    var activeTrip = TripData.lastActiveTrip;
    if (activeTrip == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BAG COMMAND CENTER',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.5,
                    color: Colors.black38,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Advanced Logistics',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 32),

                // Backpack Logistics
                _buildBagStatRow(
                  'BACKPACK (7kg MAX)',
                  activeTrip.items
                      .where((i) => i.bagId == '1' && i.isPacked)
                      .length,
                  activeTrip.items.where((i) => i.bagId == '1').length,
                  Icons.backpack_rounded,
                ),
                const SizedBox(height: 16),

                // Suitcase Logistics
                _buildBagStatRow(
                  'SUITCASE (23kg MAX)',
                  activeTrip.items
                      .where(
                        (i) => (i.bagId == '2' || i.bagId == null) && i.isPacked,
                      )
                      .length,
                  activeTrip.items
                      .where((i) => i.bagId == '2' || i.bagId == null)
                      .length,
                  Icons.luggage_rounded,
                ),

                const SizedBox(height: 48),
                Tappable(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Center(
                      child: Text(
                        'Close Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBagStatRow(String label, int packed, int total, IconData icon) {
    final progress = total == 0 ? 1.0 : packed / total;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: PackLiteTheme.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '$packed / $total items packed',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
