import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../core/data.dart';
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
  bool needsToBuy;
  String? bagId;

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
// PREMIUM GROUP TRIP SCREEN (Refactored for HQ UI)
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
  Trip? _activeTrip;

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

    if (widget.trip != null) {
      if (widget.trip!.members.length <= 1) {
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
            expandedHeight: 180, pinned: true, elevation: 0, 
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(28, 80, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_info.name.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1.5, height: 1.0)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 12, color: Colors.black26),
                                const SizedBox(width: 4),
                                Text(_info.destination.toUpperCase(), style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
                              ],
                            ),
                          ],
                        ),
                        _buildStatusBadge('MISSION: ACTIVE'),
                      ],
                    ),
                    const Spacer(),
                    _buildCleanProgress(),
                  ],
                ),
              ),
              title: const Text(''),
            ),
            actions: [
               IconButton(
                 onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SplittLiteScreen(trip: _getEffectiveTrip()))),
                 icon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.black),
               ),
               IconButton(onPressed: _showInviteSheet, icon: const Icon(Icons.person_add_rounded, color: Colors.black)),
               const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const Divider(height: 1, color: Color(0xFFF1F1ED)),
                const SizedBox(height: 24),
                _buildTabBar(),
                const SizedBox(height: 8),
              ],
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

  Widget _buildStatusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PackLiteTheme.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildCleanProgress() {
    double totalProgress = _members.map((m) => m.progress).reduce((a, b) => a + b) / _members.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             const Text('LOGISTICS STATUS', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold, fontSize: 8, letterSpacing: 1)),
             Text('${(totalProgress * 100).toInt()}%', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: totalProgress, minHeight: 4, backgroundColor: PackLiteTheme.background, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: const Color(0xFFF1F1ED), borderRadius: BorderRadius.circular(12)),
      child: TabBar(
        controller: _tabCtrl, 
        isScrollable: true, 
        tabAlignment: TabAlignment.start, 
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(horizontal: 20),
        indicator: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
        labelColor: Colors.white, 
        unselectedLabelColor: Colors.black38,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
        tabs: const [Tab(text: 'Tactical'), Tab(text: 'Personnel'), Tab(text: 'Assets'), Tab(text: 'Logistics'), Tab(text: 'Comms')],
      ),
    );
  }

  // --- TABS IMPLEMENTATIONS ---

  Widget _buildBoardTab() {
    final trip = _getEffectiveTrip();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(children: [
          Expanded(child: _buildTacticalCard('STAY', _info.hotel, Icons.hotel_rounded, Colors.orange.shade100)),
          const SizedBox(width: 16),
          Expanded(child: _buildTacticalCard('TOKEN', _inviteCode, Icons.key_rounded, Colors.blue.shade100, isCode: true)),
        ]),
        const SizedBox(height: 16),
        _buildExpenseMiniCard(),
        const SizedBox(height: 32),
        _buildToDoSection(trip),
        const SizedBox(height: 32),
        const Text('PERSONNEL OVERVIEW', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black26, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        _buildCircularTeamOverview(),
      ],
    );
  }

  Widget _buildTacticalCard(String label, String value, IconData icon, Color bg, {bool isCode = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: PackLiteTheme.cardBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 16, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 9, color: Colors.black26, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: isCode ? 18 : 15, letterSpacing: isCode ? 2 : -0.2)),
        ],
      ),
    );
  }

  Widget _buildToDoSection(Trip trip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MISSION TASKS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.black26, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F7),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: PackLiteTheme.cardBorder),
          ),
          child: Column(
            children: [
              if (trip.toDoList.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(12), child: Text('No active tasks', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold))))
              else
                ...trip.toDoList.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Tappable(
                        onTap: () => setState(() => t.isDone = !t.isDone),
                        child: Icon(t.isDone ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, size: 22, color: t.isDone ? Colors.green : Colors.black12),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: Text(t.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, decoration: t.isDone ? TextDecoration.lineThrough : null, color: t.isDone ? Colors.black26 : Colors.black))),
                    ],
                  ),
                )).toList(),
              const Divider(height: 32),
              Tappable(
                onTap: _showAddToDoDialog,
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.add_rounded, size: 14, color: Colors.white)),
                  const SizedBox(width: 12),
                  const Text('NEW STRATEGIC TASK', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5))
                ]),
              ),
            ],
          ),
        ),
      ],
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
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(32), 
                  border: Border.all(color: PackLiteTheme.cardBorder, width: 2)
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.black,
                      child: Text(m.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('${(m.progress * 100).toInt()}% OPERATIONAL', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(value: m.progress, minHeight: 6, backgroundColor: Colors.black12, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Tappable(
            onTap: _showInviteSheet,
            child: Container(
              width: double.infinity, height: 64,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(32)),
              child: const Center(child: Text('ENROLL PERSONNEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1))),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogueTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.9, mainAxisSpacing: 16, crossAxisSpacing: 16),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        final isMe = item.claimedById == 'me';
        return Tappable(
          onTap: () {
             PackLiteTheme.haptic();
             setState(() => item.claimedById = isMe ? null : 'me');
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isMe ? Colors.black : Colors.white, 
              borderRadius: BorderRadius.circular(32),
              border: isMe ? null : Border.all(color: PackLiteTheme.cardBorder, width: 2),
              boxShadow: isMe ? [BoxShadow(color: Colors.black38, blurRadius: 15, offset: const Offset(0, 8))] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 32, color: isMe ? Colors.white : Colors.black),
                const SizedBox(height: 16),
                Text(item.name, style: TextStyle(color: isMe ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 14), textAlign: TextAlign.center, maxLines: 1),
                const SizedBox(height: 4),
                Text('${(item.weight).toStringAsFixed(1)} KG', style: TextStyle(color: isMe ? Colors.white38 : Colors.black26, fontSize: 10, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                if (!isMe && item.claimedById != null)
                  Text('CLAIMED BY ${item.claimedById!.toUpperCase()}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 8))
                else if (isMe)
                  const Icon(Icons.check_circle_rounded, color: Colors.cyanAccent, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackTab() {
    final myItems = _items.where((i) => i.claimedById == 'me').toList();
    double current = myItems.where((i) => i.isPacked).fold(0, (sum, i) => sum + i.weight);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: myItems.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                 return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                    const Text('LOGISTICS STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Colors.black26)), 
                    const SizedBox(height: 12),
                    _buildLogisticsBar(current),
                    const SizedBox(height: 32),
                   ],
                 );
              }
              final item = myItems[index - 1];
              return _buildPackageTile(item);
            },
          ),
        ),
        _buildManualAddItemBar(),
      ],
    );
  }

  Widget _buildLogisticsBar(double weight) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL LOAD', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 9)),
              Text('${weight.toStringAsFixed(1)} / 7.0 KG', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(value: (weight / 7.0).clamp(0.0, 1.0), minHeight: 6, backgroundColor: Colors.white12, color: Colors.cyanAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageTile(GroupItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: item.isPacked ? const Color(0xFFF5F5F5) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: item.isPacked ? Colors.transparent : PackLiteTheme.cardBorder, width: 2),
      ),
      child: Row(
        children: [
          Tappable(
            onTap: () => setState(() => item.isPacked = !item.isPacked),
            child: Icon(item.isPacked ? Icons.check_circle_rounded : Icons.circle_outlined, size: 24, color: item.isPacked ? Colors.black : Colors.black12),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, decoration: item.isPacked ? TextDecoration.lineThrough : null, color: item.isPacked ? Colors.black38 : Colors.black)),
                if (item.bagId != null) 
                  Text('STORED IN: ${_getBagName(item.bagId).toUpperCase()}', style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 0.5)),
              ],
            ),
          ),
          if (!item.isPacked)
            IconButton(onPressed: () => _showBagPicker(item), icon: const Icon(Icons.storage_rounded, size: 18, color: Colors.black26)),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _messages.length,
            itemBuilder: (context, i) {
              final msg = _messages[i];
              if (msg.isSystem) {
                return Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(msg.text.toUpperCase(), style: const TextStyle(color: Colors.black26, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1))));
              }
              bool isMe = msg.senderId == 'me';
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.black : const Color(0xFFF1F1ED),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                      bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(20),
                    ),
                  ),
                  child: Text(msg.text, style: TextStyle(color: isMe ? Colors.white : Colors.black, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              );
            },
          ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF1F1ED)))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatMsgCtrl,
              decoration: InputDecoration(hintText: 'Transmit message...', filled: true, fillColor: const Color(0xFFF1F1ED), border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Tappable(
            onTap: () {
              if (_chatMsgCtrl.text.isEmpty) return;
              setState(() {
                _messages.add(ChatMessage(id: DateTime.now().toString(), senderId: 'me', text: _chatMsgCtrl.text, time: DateTime.now()));
                _chatMsgCtrl.clear();
              });
            },
            child: Container(height: 48, width: 48, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.send_rounded, color: Colors.white, size: 20)),
          ),
        ],
      ),
    );
  }

  // --- HELPERS FROM PREVIOUS VERSION (STABLE) ---

  void _showInviteSheet() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.white, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ENROLL PERSONNEL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: PackLiteTheme.background, borderRadius: BorderRadius.circular(24)), child: Text(_inviteCode, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 8))),
            const SizedBox(height: 24),
            const Text('Share this mission token with your team to sync logistics.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black38, fontWeight: FontWeight.w700)),
            const SizedBox(height: 32),
            Tappable(onTap: () => Navigator.pop(c), child: Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('CLOSE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))))),
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
          width: 80, margin: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              CircleAvatar(radius: 24, backgroundColor: Colors.black, child: Text(m.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10))),
              const SizedBox(height: 12),
              Text(m.name.split(' ').first, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11), maxLines: 1),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildExpenseMiniCard() {
    return Tappable(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SplittLiteScreen(trip: _getEffectiveTrip()))),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(32)),
        child: Row(
          children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TREASURY STATUS', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1.5)),
              SizedBox(height: 8),
              Text('SplittLite 2.0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
            ]),
            const Spacer(),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.payments_rounded, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  String _getBagName(String? bagId) {
    if (bagId == null) return '?';
    final bags = _getEffectiveTrip().bags;
    return bags.any((b) => b.id == bagId) ? bags.firstWhere((b) => b.id == bagId).name : 'STORAGE';
  }

  void _showBagPicker(GroupItem item) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ASSIGN ASSET STORAGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black38, letterSpacing: 2)),
            const SizedBox(height: 32),
            ...(_getEffectiveTrip().bags).map((b) => Tappable(
              onTap: () { setState(() => item.bagId = b.id); Navigator.pop(context); },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: item.bagId == b.id ? Colors.black : const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [Icon(Icons.inventory_2_rounded, color: item.bagId == b.id ? Colors.white : Colors.black), const SizedBox(width: 16), Text(b.name, style: TextStyle(fontWeight: FontWeight.w900, color: item.bagId == b.id ? Colors.white : Colors.black))]),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildManualAddItemBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF1F1ED)))),
      child: Row(
        children: [
          Expanded(child: TextField(controller: _customItemCtrl, decoration: InputDecoration(hintText: 'Add tactical gear...', filled: true, fillColor: const Color(0xFFF1F1ED), border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), onSubmitted: (v) => _addManualItem())),
          const SizedBox(width: 12),
          Tappable(onTap: _addManualItem, child: Container(height: 48, width: 48, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle), child: const Icon(Icons.add_rounded, color: Colors.white))),
        ],
      ),
    );
  }

  void _addManualItem() {
    if (_customItemCtrl.text.isEmpty) return;
    PackLiteTheme.haptic();
    setState(() { _items.add(GroupItem(id: DateTime.now().toString(), name: _customItemCtrl.text, category: 'Manual', claimedById: 'me')); _customItemCtrl.clear(); });
  }

  void _showAddToDoDialog() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      title: const Text('Add Objective', style: TextStyle(fontWeight: FontWeight.w900)),
      content: TextField(controller: ctrl, autofocus: true, decoration: const InputDecoration(hintText: 'Enter mission task')),
      actions: [Tappable(onTap: () { if (ctrl.text.isNotEmpty) setState(() => _getEffectiveTrip().toDoList.add(ToDoItem(id: DateTime.now().toString(), title: ctrl.text))); Navigator.pop(c); }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)), child: const Text('ADD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))))],
    ));
  }
}

class MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 20) {
      for (double j = 0; j < size.height; j += 20) {
        canvas.drawCircle(Offset(i, j), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
