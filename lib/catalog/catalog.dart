import 'package:flutter/material.dart';
import '../core/theme.dart';

class CatalogItem {
  final String name;
  final String category;
  bool isSelected;

  CatalogItem({required this.name, required this.category, this.isSelected = false});
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final List<CatalogItem> _allItems = [
    // Clothing
    CatalogItem(name: 'T-Shirts', category: 'Clothing'),
    CatalogItem(name: 'Cotton Shirts', category: 'Clothing'),
    CatalogItem(name: 'Linen Shirts', category: 'Clothing'),
    CatalogItem(name: 'Jeans', category: 'Clothing'),
    CatalogItem(name: 'Shorts', category: 'Clothing'),
    CatalogItem(name: 'Formal Trousers', category: 'Clothing'),
    CatalogItem(name: 'Chinos', category: 'Clothing'),
    CatalogItem(name: 'Socks', category: 'Clothing'),
    CatalogItem(name: 'Hiking Socks', category: 'Clothing'),
    CatalogItem(name: 'Underwear', category: 'Clothing'),
    CatalogItem(name: 'Swimwear', category: 'Clothing'),
    CatalogItem(name: 'Activewear Tops', category: 'Clothing'),
    CatalogItem(name: 'Yoga Pants', category: 'Clothing'),
    CatalogItem(name: 'Jacket', category: 'Clothing'),
    CatalogItem(name: 'Windbreaker', category: 'Clothing'),
    CatalogItem(name: 'Rain Coat', category: 'Clothing'),
    CatalogItem(name: 'Suit/Dress', category: 'Clothing'),
    CatalogItem(name: 'Evening Gown', category: 'Clothing'),
    CatalogItem(name: 'Thermal Wear', category: 'Clothing'),
    CatalogItem(name: 'Sweatpants', category: 'Clothing'),
    CatalogItem(name: 'Sneakers', category: 'Clothing'),
    CatalogItem(name: 'Running Shoes', category: 'Clothing'),
    CatalogItem(name: 'Sandals', category: 'Clothing'),
    CatalogItem(name: 'Flip-flops', category: 'Clothing'),
    CatalogItem(name: 'Hiking Boots', category: 'Clothing'),
    CatalogItem(name: 'Silk Pajamas', category: 'Clothing'),
    
    // Accessories
    CatalogItem(name: 'Watch', category: 'Accessories'),
    CatalogItem(name: 'Smart Watch', category: 'Accessories'),
    CatalogItem(name: 'Sunglasses', category: 'Accessories'),
    CatalogItem(name: 'Belt', category: 'Accessories'),
    CatalogItem(name: 'Leather Wallet', category: 'Accessories'),
    CatalogItem(name: 'Hat/Cap', category: 'Accessories'),
    CatalogItem(name: 'Woolen Beanie', category: 'Accessories'),
    CatalogItem(name: 'Scarf', category: 'Accessories'),
    CatalogItem(name: 'Tie', category: 'Accessories'),
    CatalogItem(name: 'Travel Umbrella', category: 'Accessories'),
    CatalogItem(name: 'Money Belt', category: 'Accessories'),
    CatalogItem(name: 'Neck Pillow', category: 'Accessories'),
    CatalogItem(name: 'Eye Mask', category: 'Accessories'),
    CatalogItem(name: 'Earplugs', category: 'Accessories'),
    CatalogItem(name: 'Jewelry Box', category: 'Accessories'),
    
    // Electronics
    CatalogItem(name: 'Laptop', category: 'Electronics'),
    CatalogItem(name: 'Tablet/iPad', category: 'Electronics'),
    CatalogItem(name: 'Phone', category: 'Electronics'),
    CatalogItem(name: 'E-Reader (Kindle)', category: 'Electronics'),
    CatalogItem(name: 'Charger', category: 'Electronics'),
    CatalogItem(name: 'Power Bank', category: 'Electronics'),
    CatalogItem(name: 'Universal Adapter', category: 'Electronics'),
    CatalogItem(name: 'Headphones', category: 'Electronics'),
    CatalogItem(name: 'Noise Cancelling Buds', category: 'Electronics'),
    CatalogItem(name: 'Camera', category: 'Electronics'),
    CatalogItem(name: 'Action Cam (GoPro)', category: 'Electronics'),
    CatalogItem(name: 'Gimbal', category: 'Electronics'),
    CatalogItem(name: 'SD Cards', category: 'Electronics'),
    CatalogItem(name: 'Portable SSD', category: 'Electronics'),
    CatalogItem(name: 'USB-C Cable', category: 'Electronics'),
    
    // Toiletries
    CatalogItem(name: 'Toothbrush', category: 'Toiletries'),
    CatalogItem(name: 'Electric Toothbrush', category: 'Toiletries'),
    CatalogItem(name: 'Toothpaste', category: 'Toiletries'),
    CatalogItem(name: 'Dental Floss', category: 'Toiletries'),
    CatalogItem(name: 'Deodorant', category: 'Toiletries'),
    CatalogItem(name: 'Shampoo', category: 'Toiletries'),
    CatalogItem(name: 'Dry Shampoo', category: 'Toiletries'),
    CatalogItem(name: 'Body Wash', category: 'Toiletries'),
    CatalogItem(name: 'Sunscreen', category: 'Toiletries'),
    CatalogItem(name: 'Moisturizer', category: 'Toiletries'),
    CatalogItem(name: 'Face Wash', category: 'Toiletries'),
    CatalogItem(name: 'Razor', category: 'Toiletries'),
    CatalogItem(name: 'Shaving Cream', category: 'Toiletries'),
    CatalogItem(name: 'Hair Gel/Wax', category: 'Toiletries'),
    CatalogItem(name: 'Makeup Kit', category: 'Toiletries'),
    CatalogItem(name: 'Perfume/Cologne', category: 'Toiletries'),
    CatalogItem(name: 'Hand Sanitizer', category: 'Toiletries'),
    CatalogItem(name: 'Wet Wipes', category: 'Toiletries'),
    CatalogItem(name: 'Nail Clipper', category: 'Toiletries'),
    CatalogItem(name: 'Tweezers', category: 'Toiletries'),
    
    // Documents
    CatalogItem(name: 'Passport', category: 'Documents'),
    CatalogItem(name: 'Visa', category: 'Documents'),
    CatalogItem(name: 'ID Card', category: 'Documents'),
    CatalogItem(name: 'Tickets', category: 'Documents'),
    CatalogItem(name: 'Hotel Vouchers', category: 'Documents'),
    CatalogItem(name: 'Insurance Policy', category: 'Documents'),
    CatalogItem(name: 'Rental Agreement', category: 'Documents'),
    CatalogItem(name: 'Vaccination Record', category: 'Documents'),
    CatalogItem(name: 'Offline Maps', category: 'Documents'),
    CatalogItem(name: 'Cash (Local)', category: 'Documents'),
    CatalogItem(name: 'Credit Cards', category: 'Documents'),
    
    // Medicines
    CatalogItem(name: 'Painkillers', category: 'Medicines'),
    CatalogItem(name: 'First Aid Kit', category: 'Medicines'),
    CatalogItem(name: 'Vitamins', category: 'Medicines'),
    CatalogItem(name: 'Band-Aids', category: 'Medicines'),
    CatalogItem(name: 'Antihistamines', category: 'Medicines'),
    CatalogItem(name: 'Digestive Tablets', category: 'Medicines'),
    CatalogItem(name: 'Motion Sickness Pills', category: 'Medicines'),
    CatalogItem(name: 'Prescriptions', category: 'Medicines'),
    CatalogItem(name: 'Antiseptic Cream', category: 'Medicines'),
    CatalogItem(name: 'Thermometer', category: 'Medicines'),
    
    // Group Gear
    CatalogItem(name: 'Tent', category: 'Group Gear'),
    CatalogItem(name: 'Stove', category: 'Group Gear'),
    CatalogItem(name: 'Speaker', category: 'Group Gear'),
    CatalogItem(name: 'Walkie Talkies', category: 'Group Gear'),
    CatalogItem(name: 'Cards/Games', category: 'Group Gear'),
    CatalogItem(name: 'Power Extension', category: 'Group Gear'),
    CatalogItem(name: 'Multi-tool', category: 'Group Gear'),
    CatalogItem(name: 'Portable Filter', category: 'Group Gear'),
    CatalogItem(name: 'Hammock', category: 'Group Gear'),
    CatalogItem(name: 'Binoculars', category: 'Group Gear'),
    CatalogItem(name: 'Camping Chairs', category: 'Group Gear'),

  ];

  String _selectedCat = 'All';
  String _query = '';
  final _searchCtrl = TextEditingController();

  final List<String> _categories = ['All', 'Clothing', 'Accessories', 'Electronics', 'Toiletries', 'Documents', 'Medicines', 'Group Gear'];

  List<CatalogItem> get _filteredItems {
    return _allItems.where((i) {
      final matchCat = _selectedCat == 'All' || i.category == _selectedCat;
      final matchQuery = i.name.toLowerCase().contains(_query.toLowerCase());
      return matchCat && matchQuery;
    }).toList();
  }

  int get _selCount => _allItems.where((i) => i.isSelected).length;

  void _confirm() {
    PackLiteTheme.haptic();
    final selectedNames = _allItems.where((i) => i.isSelected).map((i) => i.name).toList();
    Navigator.pop(context, selectedNames);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PackLiteTheme.background,
      appBar: AppBar(
        backgroundColor: PackLiteTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Item Catalogue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
        actions: [
          if (_selCount > 0)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100)),
                child: Text('$_selCount selected', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildSearch(),
          _buildCategories(),
          Expanded(child: _buildGrid()),
        ],
      ),
      bottomSheet: _selCount > 0 ? _buildBottomButton() : null,
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: 'Search items...',
          hintStyle: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w500),
          prefixIcon: Icon(Icons.search_rounded, color: PackLiteTheme.mutedText),
          suffixIcon: _query.isNotEmpty ? IconButton(icon: const Icon(Icons.close_rounded), onPressed: () { setState(() { _query = ''; _searchCtrl.clear(); }); }) : null,
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: PackLiteTheme.cardBorder)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: PackLiteTheme.cardBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 2)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final c = _categories[i];
          final isSel = _selectedCat == c;
          return Tappable(
            onTap: () => setState(() => _selectedCat = c),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: isSel ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: isSel ? null : Border.all(color: PackLiteTheme.cardBorder),
              ),
              child: Center(child: Text(c, style: TextStyle(color: isSel ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 12))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    final filtered = _filteredItems;
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: PackLiteTheme.mutedText2),
            const SizedBox(height: 16),
            Text('No items found for "$_query"', style: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final item = filtered[i];
        return Tappable(
          onTap: () => setState(() => item.isSelected = !item.isSelected),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: item.isSelected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: item.isSelected ? null : Border.all(color: PackLiteTheme.cardBorder),
            ),
            child: Row(
              children: [
                Icon(item.isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, size: 20, color: item.isSelected ? Colors.white : PackLiteTheme.mutedText),
                const SizedBox(width: 8),
                Expanded(child: Text(item.name, style: TextStyle(color: item.isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w700, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]),
      child: Tappable(
        onTap: _confirm,
        child: Container(
          width: double.infinity, height: 56,
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: Text('Add $_selCount items to list', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}