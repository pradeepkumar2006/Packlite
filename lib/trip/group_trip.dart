
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../core/data.dart';
import '../core/amazon_utils.dart';
import 'splitt_lite.dart';

// ════════════════════════════════════════════
// DATA MODELS (Local)
// ════════════════════════════════════════════
class Member {
  final String id;
  final String name;
  final String initials;
  final double progress;

  Member({required this.id, required this.name, required this.initials, this.progress = 0.0});
}

class GroupItem {
  final String id;
  final String name;
  final String category;
  final double weight;
  final IconData icon;
  String? claimedById;
  bool isPacked;
  String zone;
  bool needsToBuy; // Added
  String? bagId;   // Added

  GroupItem({
    required this.id,
    required this.name,
    required this.category,
    this.weight = 0.4,
    this.icon = Icons.inventory_2_outlined,
    this.claimedById,
    this.isPacked = false,
    this.zone = 'Main Compartment',
    this.needsToBuy = false,
    this.bagId,
  });
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime time;
  final bool isSystem;

  ChatMessage({required this.id, required this.senderId, required this.text, required this.time, this.isSystem = false});
}

class TripInfo {
  String name;
  String destination;
  String hotel;

  TripInfo({
    required this.name,
    required this.destination,
    required this.hotel,
  });
}

// ════════════════════════════════════════════
// PREMIUM GROUP TRIP SCREEN
// ════════════════════════════════════════════
class GroupTripScreen extends StatefulWidget {
  final Trip? trip;
  const GroupTripScreen({super.key, this.trip});

  @override
  State<GroupTripScreen> createState() => _GroupTripScreenState();
}

class _GroupTripScreenState extends State<GroupTripScreen> with TickerProviderStateMixin {
  late TabController _tabCtrl;
  late TripInfo _info;
  late List<GroupItem> _items;
  late List<Member> _members;
  late String _inviteCode;
  Trip? _activeTrip; // Made nullable to avoid LateInitializationError
  bool _isSuitcaseMode = true;

  final TextEditingController _customItemCtrl = TextEditingController();
  final TextEditingController _chatMsgCtrl = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(id: '1', senderId: 'system', text: 'Sam Chen joined the trip group', time: DateTime.now().subtract(const Duration(hours: 4)), isSystem: true),
    ChatMessage(id: '2', senderId: 'sam', text: 'Hey guys! Should I bring the speaker or someone else has it?', time: DateTime.now().subtract(const Duration(hours: 3))),
    ChatMessage(id: '3', senderId: 'mia', text: 'I have some card games too!', time: DateTime.now().subtract(const Duration(hours: 2))),
    ChatMessage(id: '4', senderId: 'system', text: 'Trip set for Bali next week!', time: DateTime.now().subtract(const Duration(hours: 1)), isSystem: true),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    _inviteCode = _genInviteCode();
    
    _members = [
      Member(id: 'me', name: 'You', initials: 'YOU', progress: 0.65),
      Member(id: 'sam', name: 'Sam Chen', initials: 'SC', progress: 0.20),
      Member(id: 'mia', name: 'Mia Watson', initials: 'MW', progress: 0.90),
    ];

    // Sync trip members for SplittLite
    if (widget.trip != null) {
      if (widget.trip!.members.length <= 1) { // Default is just ['You']
        widget.trip!.members.clear();
        widget.trip!.members.addAll(['You', 'Sam', 'Mia']);
      }
    }
    
    _items = [
      GroupItem(id: '1', name: 'First Aid Kit', category: 'Medical', weight: 0.5, icon: Icons.medication_rounded, claimedById: 'me', zone: 'Front Pocket'),
      GroupItem(id: '2', name: 'JBL Speaker', category: 'Electronics', weight: 0.8, icon: Icons.speaker_group_rounded, claimedById: 'sam', zone: 'Side Pocket'),
      GroupItem(id: '3', name: 'Camping Tent', category: 'Gear', weight: 3.2, icon: Icons.home_rounded, zone: 'Main Compartment'),
      GroupItem(id: '4', name: 'Board Games', category: 'Entertainment', weight: 1.2, icon: Icons.casino_rounded, claimedById: 'mia', zone: 'Main Compartment'),
      GroupItem(id: '5', name: 'Solar Charger', category: 'Electronics', weight: 0.6, icon: Icons.solar_power_rounded, zone: 'Front Pocket'),
    ];

    _info = TripInfo(
      name: widget.trip?.name ?? 'Summer Getaway',
      destination: widget.trip?.destination ?? 'Bali, Indonesia',
      hotel: 'Ametis Villa',
    );

    _activeTrip = widget.trip ?? Trip(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      name: _info.name,
      destination: _info.destination,
      type: 'Group',
      date: DateTime.now(),
      items: [],
      members: ['You', 'Sam', 'Mia'],
      currencyCode: 'IDR',
      conversionRate: 15600.0,
      weatherIcon: '🌴',
      temperature: '28°',
    );
  }

  String _genInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  Trip _getEffectiveTrip() {
    if (_activeTrip != null) return _activeTrip!;
    _activeTrip = widget.trip ?? Trip(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      name: _info.name,
      destination: _info.destination,
      type: 'Group',
      date: DateTime.now(),
      items: [],
      members: ['You', 'Sam', 'Mia'],
    );
    return _activeTrip!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260, pinned: true, elevation: 0, backgroundColor: Colors.black,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    Positioned(
                      right: -30, top: -30,
                      child: Opacity(opacity: 0.05, child: Icon(Icons.public_rounded, size: 300, color: Colors.white)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 100, 28, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(100)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                const Text('LIVE SYNC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(_info.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1.5, height: 1.1)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: Colors.white38),
                              const SizedBox(width: 8),
                              Text(_info.destination.toUpperCase(), style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              title: const Text(''),
            ),
            actions: [
               IconButton(
                 onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SplittLiteScreen(trip: _getEffectiveTrip()))),
                 icon: const Icon(Icons.payments_outlined, color: Colors.white),
                 tooltip: 'SplittLite',
               ),
               IconButton(onPressed: _showInviteSheet, icon: const Icon(Icons.person_add_rounded, color: Colors.white)),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
              child: _buildTabBar(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _buildBoardTab(),
                _buildTeamTab(),
                _buildCatalogueTab(),
                _buildPackTab(),
                _buildChatTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F1ED), borderRadius: BorderRadius.circular(20)),
      child: TabBar(
        controller: _tabCtrl, isScrollable: true, tabAlignment: TabAlignment.start, dividerColor: Colors.transparent,
        indicator: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
        labelColor: Colors.white, unselectedLabelColor: Colors.black26,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
        tabs: const [Tab(text: 'Board'), Tab(text: 'Team'), Tab(text: 'Catalogue'), Tab(text: 'Pack'), Tab(text: 'Chat')],
      ),
    );
  }

  Widget _buildBoardTab() {
    final trip = _getEffectiveTrip();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildStatCard('Destination', _info.destination, Icons.location_on_rounded),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _buildStatCard('Stay', _info.hotel, Icons.hotel_rounded)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('Trip Code', _inviteCode, Icons.vpn_key_rounded, isCode: true)),
        ]),
        const SizedBox(height: 16),
        _buildExpenseMiniCard(),
        const SizedBox(height: 32),
        _buildToDoSection(trip),
        const SizedBox(height: 32),
        const Text('TEAM OVERVIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black38)),
        const SizedBox(height: 16),
        _buildCircularTeamOverview(),
      ],
    );
  }

  Widget _buildToDoSection(Trip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('TRIP TASKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black38, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: PackLiteTheme.background, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              if (trip.toDoList.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(12), child: Text('No tasks added yet', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold))))
              else
                ...trip.toDoList.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Tappable(
                        onTap: () => setState(() => t.isDone = !t.isDone),
                        child: Icon(t.isDone ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, size: 20, color: t.isDone ? Colors.black : Colors.black26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(t.title, style: TextStyle(fontWeight: FontWeight.w700, decoration: t.isDone ? TextDecoration.lineThrough : null, color: t.isDone ? Colors.black38 : Colors.black))),
                    ],
                  ),
                )).toList(),
              const Divider(height: 32),
              Tappable(
                onTap: _showAddToDoDialog,
                child: const Row(children: [Icon(Icons.add_task_rounded, size: 20), SizedBox(width: 12), Text('ADD TRIP TASK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddToDoDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: ctrl, autofocus: true,
          decoration: InputDecoration(hintText: 'e.g. Confirm hotel booking', filled: true, fillColor: PackLiteTheme.background, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
        ),
        actions: [
          Tappable(
            onTap: () {
              if (ctrl.text.isEmpty) return;
              setState(() => _getEffectiveTrip().toDoList.add(ToDoItem(id: DateTime.now().toString(), title: ctrl.text)));
              Navigator.pop(context);
            },
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)), child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseMiniCard() {
    return Tappable(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SplittLiteScreen(trip: _getEffectiveTrip()))),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))]),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL EXPENSES', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Splitt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
                    Text('Lite', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {bool isCode = false}) {
    return Tappable(
      onTap: isCode ? _showInviteSheet : () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: PackLiteTheme.cardBorder)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: Colors.black38),
                const SizedBox(width: 8),
                Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1.2, color: Colors.black38)),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: isCode ? 18 : 16, 
                letterSpacing: isCode ? 4 : -0.2, 
                color: Colors.black
              ),
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularTeamOverview() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _members.map((m) => Container(
          width: 80,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 52, height: 52,
                    child: CircularProgressIndicator(
                      value: (m.progress).toDouble(), 
                      strokeWidth: 3, 
                      backgroundColor: Colors.black.withValues(alpha: 0.05), 
                      color: Colors.black
                    ),
                  ),
                  CircleAvatar(
                    radius: 20, 
                    backgroundColor: Colors.black, 
                    child: Text(m.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10))
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                m.name.split(' ').first, 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black),
                maxLines: 1, overflow: TextOverflow.ellipsis
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTeamTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _members.length,
            itemBuilder: (context, i) {
              final m = _members[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(28), 
                  border: Border.all(color: PackLiteTheme.cardBorder)
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.black,
                      child: Text(m.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('${(m.progress * 100).toInt()}% READY', style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w900, fontSize: 10)),
                        ],
                      ),
                    ),
                    Container(
                      width: 50, height: 6,
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(100)),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: m.progress,
                        child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100))),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Tappable(
            onTap: _showInviteSheet,
            child: Container(
              width: double.infinity, height: 64,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  Icon(Icons.person_add_rounded, color: Colors.white, size: 20), 
                  SizedBox(width: 12), 
                  Text('INVITE FRIENDS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1))
                ]
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogueTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, mainAxisSpacing: 16, crossAxisSpacing: 16),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        final isMe = item.claimedById == 'me';
        return Tappable(
          onTap: () => setState(() => item.claimedById = isMe ? null : 'me'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isMe ? Colors.black : Colors.white, 
              borderRadius: BorderRadius.circular(28),
              border: isMe ? null : Border.all(color: PackLiteTheme.cardBorder),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 24, color: isMe ? Colors.white : Colors.black),
                const SizedBox(height: 12),
                Text(item.name, style: TextStyle(color: isMe ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${(item.weight).toDouble().toStringAsFixed(1)} KG', style: TextStyle(color: isMe ? Colors.white54 : Colors.black26, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
        );
      },
    );
  }


  String _getBagName(String? bagId) {
    if (bagId == null) return 'No Bag';
    final bags = _getEffectiveTrip().bags;
    final bag = bags.firstWhere((b) => b.id == bagId, orElse: () => Bag(id: '?', name: '?', type: '?'));
    return bag.name;
  }

  void _showBagPicker(GroupItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ASSIGN TO CONTAINER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1.5)),
            const SizedBox(height: 16),
            const Text('Choose where to pack this item', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 32),
            ...(_getEffectiveTrip().bags).map((b) => Tappable(
              onTap: () {
                setState(() => item.bagId = b.id);
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: item.bagId == b.id ? Colors.black : PackLiteTheme.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(b.type == 'Backpack' ? Icons.backpack_rounded : Icons.luggage_rounded, color: item.bagId == b.id ? Colors.white : Colors.black),
                    const SizedBox(width: 16),
                    Text(b.name, style: TextStyle(fontWeight: FontWeight.w900, color: item.bagId == b.id ? Colors.white : Colors.black)),
                    const Spacer(),
                    if (item.bagId == b.id) const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            )).toList(),
            Tappable(
              onTap: () {
                setState(() => item.bagId = null);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                child: const Center(child: Text('Clear Assignment', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold))),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPackTab() {
    final myItems = _items.where((i) => i.claimedById == 'me').toList();
    double current = 0.0;
    for (var i in myItems) {
      if (i.isPacked) {
        current += i.weight;
      }
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: myItems.length + 2, // +1 for header, +1 for Edit List footer
            itemBuilder: (context, index) {
              if (index == 0) {
                 return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                    Row(children: [
                      const Text('READY TO FLY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.2, color: Colors.black38)), 
                      const Spacer(), 
                      Transform.scale(scale: 0.8, child: Switch.adaptive(value: _isSuitcaseMode, activeColor: Colors.black, onChanged: (v) => setState(() => _isSuitcaseMode = v))),
                    ]),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(value: (current / 7.0).toDouble().clamp(0.0, 1.0), minHeight: 8, backgroundColor: Colors.black.withValues(alpha: 0.05), color: Colors.black),
                    ),
                    const SizedBox(height: 32),
                   ],
                 );
              }
              
              if (index == myItems.length + 1) {
                return _buildEditListSection();
              }
              
              final item = myItems[index - 1];
              return Dismissible(
                key: Key('group_item_${item.id}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {},
                confirmDismiss: (dir) async {
                  if (dir == DismissDirection.endToStart) {
                    _showBagPicker(item);
                    return false;
                  }
                  return false;
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(28)),
                  child: const Icon(Icons.luggage_rounded, color: Colors.white, size: 24),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: item.isPacked ? Colors.black.withValues(alpha: 0.02) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: item.isPacked ? Colors.black.withValues(alpha: 0.05) : PackLiteTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Tappable(
                        onTap: () => setState(() => item.isPacked = !item.isPacked),
                        child: Icon(
                          item.isPacked ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                          color: item.isPacked ? Colors.black : Colors.black26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Tappable(
                          onTap: () => _showBagPicker(item),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, decoration: item.isPacked ? TextDecoration.lineThrough : null, color: item.isPacked ? Colors.black38 : Colors.black)),
                              if (item.bagId != null)
                                Text(_getBagName(item.bagId).toUpperCase(), style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1)),
                              if (item.needsToBuy && !item.isPacked)
                                const Text('NEEDS TO BUY', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                      ),
                      if (!item.isPacked) ...[
                        Tappable(
                          onTap: () => setState(() => item.needsToBuy = !item.needsToBuy),
                          child: Icon(
                            item.needsToBuy ? Icons.shopping_cart_rounded : Icons.add_shopping_cart_rounded,
                            size: 18, color: item.needsToBuy ? Colors.orange : Colors.black26,
                          ),
                        ),
                        if (item.needsToBuy)
                          const SizedBox(width: 12),
                        if (item.needsToBuy)
                          Tappable(
                            onTap: () => AmazonUtils.launch(item.name),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.white),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _buildManualAddItemBar(),
      ],
    );
  }

  Widget _buildManualAddItemBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(28, 16, 28, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05)))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customItemCtrl,
              decoration: InputDecoration(
                hintText: 'Add custom item...', 
                hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black26),
                filled: true, fillColor: const Color(0xFFF1F1ED),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onSubmitted: (_) => _addManualItem(),
            ),
          ),
          const SizedBox(width: 12),
          Tappable(
            onTap: _addManualItem,
            child: Container(
              height: 48, width: 48,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _addManualItem() {
    if (_customItemCtrl.text.isEmpty) return;
    PackLiteTheme.haptic();
    setState(() {
      _items.add(GroupItem(id: DateTime.now().toString(), name: _customItemCtrl.text, category: 'Manual', claimedById: 'me'));
      _customItemCtrl.clear();
    });
  }

  Widget _buildEditListSection() {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 40),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Icon(Icons.edit_note_rounded, color: Colors.white24, size: 32),
          const SizedBox(height: 16),
          const Text('MANAGE GROUP LIST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Refine team items or reset the master list.', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Tappable(
                  onTap: () => setState(() => _tabCtrl.animateTo(4)), // Move to Catalogue
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text('EDIT MODE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Tappable(
                  onTap: () {
                    PackLiteTheme.haptic();
                    setState(() => _items.clear());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text('RESET ALL', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 12))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages.reversed.toList()[index];
              if (msg.isSystem) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(100)),
                    child: Text(msg.text.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.black38, letterSpacing: 1.5)),
                  ),
                );
              }

              final isMe = msg.senderId == 'me';
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 6),
                        child: Text(msg.senderId.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.black26, letterSpacing: 1.2)),
                      ),
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(24),
                          topRight: const Radius.circular(24),
                          bottomLeft: Radius.circular(isMe ? 24 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 24),
                        ),
                        border: isMe ? null : Border.all(color: PackLiteTheme.cardBorder),
                        boxShadow: isMe ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8))] : null,
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(color: isMe ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        _buildChatInputBar(),
      ],
    );
  }

  Widget _buildChatInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(28, 16, 28, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 30, offset: const Offset(0, -10))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: const Color(0xFFF1F1ED), borderRadius: BorderRadius.circular(100)),
              child: TextField(
                controller: _chatMsgCtrl,
                decoration: const InputDecoration(
                  hintText: 'Share something...', 
                  hintStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black26),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                onSubmitted: (_) => _sendChatMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Tappable(
            onTap: _sendChatMessage,
            child: Container(
              height: 48, width: 48,
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _sendChatMessage() {
    if (_chatMsgCtrl.text.isEmpty) return;
    PackLiteTheme.haptic();
    setState(() {
      _messages.add(ChatMessage(id: DateTime.now().toString(), senderId: 'me', text: _chatMsgCtrl.text, time: DateTime.now()));
      _chatMsgCtrl.clear();
    });
  }

  void _showInviteSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('INVITE FRIENDS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black38, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          const Text('Share this code with your group', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(color: PackLiteTheme.background, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text(_inviteCode, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 4))),
          ),
          const SizedBox(height: 32),
          Tappable(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _inviteCode));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied to clipboard!')));
            },
            child: Container(
              width: double.infinity, height: 60,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Text('COPY CODE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
            ),
          ),
        ]),
      ),
    );
  }
}
