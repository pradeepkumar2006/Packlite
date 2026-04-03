import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/data.dart';
import 'suit_painter.dart';
import '../core/ai_service.dart';


class SoloTripScreen extends StatefulWidget {
  final Trip? trip;
  const SoloTripScreen({super.key, this.trip});

  @override
  State<SoloTripScreen> createState() => _SoloTripScreenState();
}

class _SoloTripScreenState extends State<SoloTripScreen> with TickerProviderStateMixin {
  late TabController _tabCtrl;
  late String _id;
  late String _destination;
  late List<PackItem> _items;
  late List<ToDoItem> _todos;
  bool _isCompleted = false;

  final _addCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  String _selectedCat = 'Clothing';

  final List<PackItem> _masterCatalog = [
    PackItem(name: 'T-Shirts', category: 'Clothing'),
    PackItem(name: 'Jeans', category: 'Clothing'),
    PackItem(name: 'Shorts', category: 'Clothing'),
    PackItem(name: 'Socks', category: 'Clothing'),
    PackItem(name: 'Underwear', category: 'Clothing'),
    PackItem(name: 'Swimwear', category: 'Clothing'),
    PackItem(name: 'Jacket', category: 'Clothing'),
    PackItem(name: 'Sneakers', category: 'Clothing'),
    PackItem(name: 'Sandals', category: 'Clothing'),
    PackItem(name: 'Watch', category: 'Accessories'),
    PackItem(name: 'Sunglasses', category: 'Accessories'),
    PackItem(name: 'Belt', category: 'Accessories'),
    PackItem(name: 'Hat', category: 'Accessories'),
    PackItem(name: 'Laptop', category: 'Electronics'),
    PackItem(name: 'Phone', category: 'Electronics'),
    PackItem(name: 'Charger', category: 'Electronics'),
    PackItem(name: 'Power Bank', category: 'Electronics'),
    PackItem(name: 'Headphones', category: 'Electronics'),
    PackItem(name: 'Toothbrush', category: 'Toiletries'),
    PackItem(name: 'Toothpaste', category: 'Toiletries'),
    PackItem(name: 'Deodorant', category: 'Toiletries'),
    PackItem(name: 'Sunscreen', category: 'Toiletries'),
    PackItem(name: 'Passport', category: 'Documents'),
    PackItem(name: 'Visa', category: 'Documents'),
    PackItem(name: 'Tickets', category: 'Documents'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _id = widget.trip?.id ?? DateTime.now().toString();
    _destination = widget.trip?.destination ?? 'Paris';
    _items = List.from(widget.trip?.items ?? [
      PackItem(name: 'T-Shirts', category: 'Clothing'),
      PackItem(name: 'Jeans', category: 'Clothing'),
      PackItem(name: 'Sneakers', category: 'Clothing'),
      PackItem(name: 'Laptop', category: 'Electronics'),
      PackItem(name: 'Phone', category: 'Electronics'),
      PackItem(name: 'Charger', category: 'Electronics'),
      PackItem(name: 'Toothbrush', category: 'Toiletries'),
      PackItem(name: 'Toothpaste', category: 'Toiletries'),
      PackItem(name: 'Passport', category: 'Documents'),
    ]);
    _todos = List.from(widget.trip?.toDoList ?? []);
    _isCompleted = widget.trip?.isCompleted ?? false;
  }

  void _saveLocalToGlobal() {
    TripData.addOrUpdateTrip(Trip(
      id: _id,
      name: 'Solo Trip to $_destination',
      destination: _destination,
      type: 'Solo',
      date: DateTime.now(),
      items: _items,
      toDoList: _todos,
      isCompleted: _isCompleted,
      currencyCode: widget.trip?.currencyCode ?? 'USD',
      conversionRate: widget.trip?.conversionRate ?? 1.0,
      weatherIcon: widget.trip?.weatherIcon ?? '☀️',
      temperature: widget.trip?.temperature ?? '--°',
    ));
  }

  void _completeTrip() {
    PackLiteTheme.haptic();
    setState(() => _isCompleted = true);
    _saveLocalToGlobal();
    Navigator.pop(context, true);
  }

  void _showDestinationDialog() {
    _destCtrl.text = _destination;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Set Destination', style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: _destCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Tokyo, London',
            filled: true, fillColor: PackLiteTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          Tappable(
            onTap: () {
              if (_destCtrl.text.isNotEmpty) {
                setState(() {
                  _destination = _destCtrl.text;
                });
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
              child: const Text('Set', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    if (_addCtrl.text.isEmpty) return;
    PackLiteTheme.haptic();
    setState(() {
      _items.add(PackItem(name: _addCtrl.text, category: _selectedCat));
      _addCtrl.clear();
    });
    _saveLocalToGlobal();
  }

  double get _progress {
    if (_items.isEmpty) return 0.0;
    return _items.where((i) => i.isPacked).length / _items.length;
  }

  @override
  Widget build(BuildContext context) {
    final is100Packed = _progress == 1.0 && _items.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Tappable(
          onTap: _showDestinationDialog,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Packing List', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, size: 12, color: Colors.black),
                  const SizedBox(width: 4),
                  Text(_destination, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.black)),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.black),
                  if (_isCompleted) ...[
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)), child: const Text('DONE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900))),
                  ],
                ],
              ),
            ],
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100)),
              child: Text('${_items.length} items', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildVisualSuitcaseSection()),
          SliverToBoxAdapter(child: _buildWeightEstimationSection()),
          SliverToBoxAdapter(child: _buildDocumentCarousel()),
          SliverToBoxAdapter(child: _buildAIPackingAssistant()),
          SliverToBoxAdapter(child: _buildBudgetHealthSection()),

          if (is100Packed)
            SliverToBoxAdapter(child: _buildCompleteSummary())
          else ...[
             SliverToBoxAdapter(
               child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFFE5E5E0).withValues(alpha: 0.8), borderRadius: BorderRadius.circular(20)),
                    child: TabBar(
                      controller: _tabCtrl,
                      indicator: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(0xFF888880),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [Tab(text: 'Tasks'), Tab(text: 'Discovery'), Tab(text: 'Catalogue'), Tab(text: 'Suitcase')],
                    ),
                  ),
               ),
             ),
             SliverFillRemaining(
               child: TabBarView(
                 controller: _tabCtrl,
                 children: [
                   _buildTasksTab(),
                   _buildDiscoveryTab(),
                   _buildCatalogueTab(),
                   _buildSuitcaseTab(),
                 ],
               ),
             ),
          ],
        ],
      ),
      bottomNavigationBar: !is100Packed ? _buildInputBar() : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CURRENT STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Colors.black26)),
          const SizedBox(height: 12),
          Text(_progress == 1.0 ? 'Ready to fly!' : 'Packing in progress', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
          Text('Heading towards $_destination', style: TextStyle(color: Colors.black.withValues(alpha: 0.4), fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAIPackingAssistant() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AIService.getPackingSuggestions(_destination),

      builder: (context, snapshot) {
        String tip = "Heading to $_destination? Don't forget your essentials!";
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          tip = "${snapshot.data!.first['name']}: ${snapshot.data!.first['reason']}";
        }

        return Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withValues(alpha: 0.04), Colors.black.withValues(alpha: 0.01)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.black,
                radius: 12,
                child: Icon(Icons.auto_awesome, color: Colors.white, size: 10),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SMART INSIGHT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1, color: Colors.black)),
                    const SizedBox(height: 2),
                    Text(tip, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCatalogueTab() {
    final categories = ['Clothing', 'Accessories', 'Electronics', 'Toiletries', 'Documents'];
    final filteredCatalog = _masterCatalog.where((i) => i.category == _selectedCat).toList();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: categories.map((cat) {
              final isSelected = _selectedCat == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tappable(
                  onTap: () => setState(() => _selectedCat = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              childAspectRatio: 2.2, 
              crossAxisSpacing: 12, 
              mainAxisSpacing: 12,
            ),
            itemCount: filteredCatalog.length,
            itemBuilder: (context, index) {
              final catItem = filteredCatalog[index];
              final bool isSelected = _items.any((i) => i.name == catItem.name);

              return Tappable(
                onTap: () {
                   setState(() {
                     if (isSelected) {
                       _items.removeWhere((i) => i.name == catItem.name);
                     } else {
                       _items.add(PackItem(name: catItem.name, category: catItem.category));
                     }
                   });
                   _saveLocalToGlobal();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? Colors.black : PackLiteTheme.cardBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? Colors.white : const Color(0xFFC0C0C0), width: 2),
                          color: isSelected ? Colors.white : Colors.transparent,
                        ),
                        child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.black) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          catItem.name, 
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black, 
                            fontWeight: FontWeight.w900, 
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AIService.getPackingSuggestions(_destination),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 48, color: Colors.black.withOpacity(0.05)),
                const SizedBox(height: 16),
                const Text('Analyzing trip requirements...', 
                  style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SMART RECOMMENDATIONS', 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2, color: Colors.black26)),
                    const SizedBox(height: 8),
                    Text('AI curated essentials for $_destination', 
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final suggestion = snapshot.data![index];
                    final isAlreadyIn = _items.any((i) => i.name == suggestion['name']);
                    
                    return Tappable(
                      onTap: () {
                        if (isAlreadyIn) return;
                        PackLiteTheme.haptic();
                        setState(() {
                          _items.add(PackItem(name: suggestion['name'], category: suggestion['category']));
                        });
                        _saveLocalToGlobal();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isAlreadyIn ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: isAlreadyIn ? Colors.black : PackLiteTheme.cardBorder, width: 2),
                          boxShadow: isAlreadyIn ? [] : [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isAlreadyIn ? Colors.white24 : Colors.black.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(suggestion['category'].toString().toUpperCase(), 
                                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1, color: isAlreadyIn ? Colors.white : Colors.black54)),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isAlreadyIn) const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(suggestion['name'], 
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isAlreadyIn ? Colors.white : Colors.black, letterSpacing: -0.5)),
                                  const SizedBox(height: 6),
                                  Text(suggestion['reason'], 
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4, color: isAlreadyIn ? Colors.white60 : Colors.black38)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isAlreadyIn ? Colors.white10 : Colors.black,
                              ),
                              child: Icon(
                                isAlreadyIn ? Icons.done_all_rounded : Icons.add_rounded, 
                                color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: snapshot.data!.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildAISuggestionRow() {
    return const SizedBox.shrink(); // Obsolete, replaced by Discovery tab
  }

  void _launchAmazon(String query) async {
    final url = Uri.parse('https://www.amazon.com/s?k=$query');
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch Amazon: $e');
    }
  }

  String _getBagName(String? bagId) {
    if (bagId == null) return 'No Bag';
    final bags = widget.trip?.bags ?? [Bag(id: '1', name: 'Backpack', type: 'Backpack'), Bag(id: '2', name: 'Main Luggage', type: 'Luggage')];
    final bag = bags.firstWhere((b) => b.id == bagId, orElse: () => Bag(id: '?', name: '?', type: '?'));
    return bag.name;
  }

  void _showBagPicker(PackItem item) {
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
            ...(widget.trip?.bags ?? [Bag(id: '1', name: 'Backpack', type: 'Backpack'), Bag(id: '2', name: 'Main Luggage', type: 'Luggage')]).map((b) => Tappable(
              onTap: () {
                setState(() => item.bagId = b.id);
                _saveLocalToGlobal();
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
                _saveLocalToGlobal();
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

  Widget _buildSuitcaseTab() {
    if (_items.isEmpty) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Icon(Icons.luggage_outlined, size: 64, color: Colors.black.withValues(alpha: 0.1)),
              const SizedBox(height: 16),
              const Text('Your suitcase is empty', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Select items from Catalogue', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w500, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final shoppingItems = _items.where((i) => i.needsToBuy).toList();
    final sortedItems = List<PackItem>.from(_items)..sort((a, b) {
      if (a.isPacked == b.isPacked) return 0;
      return a.isPacked ? 1 : -1;
    });

    return Column(
      children: [
        if (shoppingItems.isNotEmpty) _buildShoppingSummary(shoppingItems),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(_progress * 100).toInt()}% READY', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Colors.black54)),
              Text('${_items.where((i) => i.isPacked).length}/${_items.length}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: sortedItems.length + 1,
            itemBuilder: (context, index) {
              if (index == sortedItems.length) return _buildEditListSection();
              final item = sortedItems[index];

              return Dismissible(
                key: Key('item_${item.name}_${index}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {}, // We don't want to actually remove it
                confirmDismiss: (dir) async {
                  if (dir == DismissDirection.endToStart) {
                    _showBagPicker(item);
                    return false; // Don't remove tile
                  }
                  return false;
                },
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('MOVE TO BAG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                      SizedBox(width: 12),
                      Icon(Icons.luggage_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.isPacked ? Colors.black.withValues(alpha: 0.03) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: item.isPacked ? Colors.black.withValues(alpha: 0.05) : PackLiteTheme.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Tappable(
                        onTap: () {
                          setState(() => item.isPacked = !item.isPacked);
                          _saveLocalToGlobal();
                        },
                        child: Icon(
                          item.isPacked ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                          color: item.isPacked ? Colors.black : Colors.black26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Tappable(
                           onTap: () => _showBagPicker(item),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 item.name,
                                 style: TextStyle(
                                   fontWeight: FontWeight.w900,
                                   fontSize: 14,
                                   decoration: item.isPacked ? TextDecoration.lineThrough : null,
                                   color: item.isPacked ? Colors.black38 : Colors.black,
                                 ),
                               ),
                               if (item.bagId != null)
                                 Text(_getBagName(item.bagId).toUpperCase(), style: const TextStyle(color: Colors.black38, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1)),
                               if (item.needsToBuy && !item.isPacked)
                                 const Text('NEEDS TO BUY', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 9)),
                             ],
                           ),
                        ),
                      ),
                      if (!item.isPacked) ...[
                        Tappable(
                          onTap: () {
                            setState(() => item.needsToBuy = !item.needsToBuy);
                            _saveLocalToGlobal();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.needsToBuy ? Colors.orange.withValues(alpha: 0.1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.needsToBuy ? Icons.shopping_cart_rounded : Icons.add_shopping_cart_rounded,
                              size: 18,
                              color: item.needsToBuy ? Colors.orange : Colors.black26,
                            ),
                          ),
                        ),
                        if (item.needsToBuy)
                          Tappable(
                            onTap: () => _launchAmazon(item.name),
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.white),
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
      ],
    );
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
          const Text('MANAGE PACKING LIST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Refine your items or reset choices.', style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Tappable(
                  onTap: () => setState(() => _tabCtrl.animateTo(2)), // Move to Catalogue
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
                    _saveLocalToGlobal();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text('RESET LIST', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 12))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingSummary(List<PackItem> items) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_cart_outlined, size: 16, color: Colors.orange),
              SizedBox(width: 8),
              Text('TRIP SHOPPING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Text('You have ${items.length} items to buy before the trip.', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildVisualSuitcaseSection() {
    final is100 = _progress == 1.0;
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 240, height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 15)),
              ],
            ),
            child: Icon(
              is100 ? Icons.luggage_rounded : Icons.luggage_outlined, 
              size: 100, 
              color: Colors.black.withValues(alpha: 0.02),
            ),
          ),
          Container(
            width: 260, height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(48),
              border: Border.all(color: Colors.black.withValues(alpha: 0.03), width: 3),
            ),
            child: CustomPaint(
              painter: SuitcaseBorderPainter(progress: _progress),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               AnimatedSwitcher(
                 duration: const Duration(milliseconds: 500),
                 child: Text(
                   '${(_progress * 100).toInt()}%',
                   key: ValueKey(_progress),
                   style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 54, letterSpacing: -2, color: Colors.black),
                 ),
               ),
               Text(
                 is100 ? 'ZIPPED & READY' : 'PACKING...',
                 style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: Colors.black38),
               ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightEstimationSection() {
    final packedWeight = widget.trip?.packedWeightKg ?? 0.0;
    const weightLimit = 7.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: PackLiteTheme.cardBorder)),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ESTIMATED WEIGHT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: Colors.black26)),
              SizedBox(height: 4),
              Text('⚖️ Cabin Bag', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
            ]),
            Text('${packedWeight.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
          ]),
          const SizedBox(height: 20),
          Stack(children: [
            Container(height: 12, decoration: BoxDecoration(color: PackLiteTheme.background, borderRadius: BorderRadius.circular(100))),
            AnimatedContainer(duration: const Duration(milliseconds: 600), height: 12, width: (MediaQuery.of(context).size.width - 100) * (packedWeight / weightLimit).clamp(0.0, 1.0), decoration: BoxDecoration(color: packedWeight > weightLimit ? Colors.red.shade400 : Colors.black, borderRadius: BorderRadius.circular(100))),
          ]),
        ]),
      ),
    );
  }

  Widget _buildDocumentCarousel() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10), child: Text('TRIP VAULT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Colors.black26))),
      SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [
        _docCard('Flight Ticket', Icons.airplane_ticket_rounded, 'Boarding 08:30'),
        _docCard('Hotel Booking', Icons.hotel_outlined, 'Check-in: 14:00'),
        _docCard('Travel Insurance', Icons.security_rounded, 'Active #V982'),
      ]))
    ]);
  }

  Widget _docCard(String title, IconData icon, String detail) {
    return Container(width: 140, margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: PackLiteTheme.cardBorder)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 24, color: Colors.black), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, height: 1.1)), const SizedBox(height: 4), Text(detail, style: const TextStyle(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.w600))]));
  }

  Widget _buildBudgetHealthSection() {
    final t = widget.trip;
    if (t == null) return const SizedBox.shrink();
    return Container(padding: const EdgeInsets.symmetric(horizontal: 28), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('BUDGET HEALTH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Colors.black26)),
      const SizedBox(height: 12),
      Row(children: [Text('\$${t.totalSpent.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)), const SizedBox(width: 8), const Text('spent', style: TextStyle(color: Colors.black26, fontSize: 12, fontWeight: FontWeight.w700)), const Spacer(), const Text('GOAL: \$1000', style: TextStyle(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w900))]),
      const SizedBox(height: 8),
      ClipRRect(borderRadius: BorderRadius.circular(100), child: LinearProgressIndicator(value: t.totalSpent / 1000.0, minHeight: 6, backgroundColor: Colors.black.withValues(alpha: 0.05), color: t.totalSpent > 800 ? Colors.red.shade400 : Colors.black)),
      const SizedBox(height: 20),
    ]));
  }

  Widget _buildCompleteSummary() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 32),
      Tappable(onTap: _completeTrip, child: Container(width: double.infinity, height: 60, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('COMPLETE PACKING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1))))),
      const SizedBox(height: 64),
    ]));
  }

  Widget _buildEmptyTasks() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt_rounded, size: 60, color: Colors.black.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            const Text('No trip tasks set', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Focus on packing first!', style: TextStyle(color: Colors.black26, fontWeight: FontWeight.w500, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab() {
    if (_todos.isEmpty) return _buildEmptyTasks();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final taskItem = _todos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: taskItem.isDone ? Colors.black.withValues(alpha: 0.03) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: taskItem.isDone ? Colors.black.withValues(alpha: 0.05) : PackLiteTheme.cardBorder),
          ),
          child: Row(
            children: [
              Tappable(
                onTap: () {
                  setState(() => taskItem.isDone = !taskItem.isDone);
                  _saveLocalToGlobal();
                },
                child: Icon(
                  taskItem.isDone ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                  color: taskItem.isDone ? Colors.black : Colors.black26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  taskItem.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    decoration: taskItem.isDone ? TextDecoration.lineThrough : null,
                    color: taskItem.isDone ? Colors.black38 : Colors.black,
                  ),
                ),
              ),
              Tappable(
                onTap: () {
                  setState(() => _todos.removeAt(index));
                  _saveLocalToGlobal();
                },
                child: const Icon(Icons.close_rounded, size: 16, color: Colors.black12),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addTask() {
    if (_addCtrl.text.isEmpty) return;
    PackLiteTheme.haptic();
    setState(() {
      _todos.add(ToDoItem(id: DateTime.now().toString(), title: _addCtrl.text));
      _addCtrl.clear();
    });
    _saveLocalToGlobal();
  }

  Widget _buildInputBar() {
    final isTaskTab = _tabCtrl.index == 0;
    return Container(
      padding: EdgeInsets.fromLTRB(28, 16, 28, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(color: Color(0xFFF9F9F7)),
      child: Row(children: [
        Expanded(child: TextField(
          controller: _addCtrl, 
          onSubmitted: (_) => isTaskTab ? _addTask() : _addItem(),
          decoration: InputDecoration(
            hintText: isTaskTab ? 'Add trip task...' : 'Add item manually...', 
            hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3), fontWeight: FontWeight.w800, fontSize: 18), 
            filled: true, fillColor: const Color(0xFFF1F1ED), 
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), 
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20)
          )
        )),
        const SizedBox(width: 16),
        Tappable(onTap: isTaskTab ? _addTask : _addItem, child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.add_rounded, color: Colors.white, size: 28))),
      ]),
    );
  }
}