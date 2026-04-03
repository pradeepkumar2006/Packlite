import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/data.dart';
import '../core/ai_service.dart';
import 'solo_trip.dart';

class SoloSetupScreen extends StatefulWidget {
  const SoloSetupScreen({super.key});

  @override
  State<SoloSetupScreen> createState() => _SoloSetupScreenState();
}

class _SoloSetupScreenState extends State<SoloSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedTemplate = 'Empty';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _templates = [
    {'name': 'Empty', 'icon': Icons.add_rounded, 'desc': 'Start from scratch'},
    {'name': 'Beach', 'icon': Icons.beach_access_rounded, 'desc': 'Sun & Sand'},
    {'name': 'Business', 'icon': Icons.business_center_rounded, 'desc': 'Corporate'},
    {'name': 'Alpine', 'icon': Icons.terrain_rounded, 'desc': 'Mountain'},
    {'name': 'AI Magic', 'icon': Icons.auto_awesome_rounded, 'desc': 'Smart AI'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Solo Journey', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Plan your escape', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1)),
                const SizedBox(height: 8),
                Text('Customize your packing experience.', style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 48),
                _buildField('Trip Name', 'e.g. My Paris Adventure', _nameController),
                const SizedBox(height: 24),
                _buildField('Destination', 'e.g. Paris, France', _destController),
                const SizedBox(height: 24),
                const Text('CHOOSE TEMPLATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: Colors.black38)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _templates.length,
                    itemBuilder: (context, i) {
                      final t = _templates[i];
                      final isSelected = _selectedTemplate == t['name'];
                      return Tappable(
                        onTap: () => setState(() => _selectedTemplate = t['name']),
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : PackLiteTheme.background,
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected ? null : Border.all(color: PackLiteTheme.cardBorder),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(t['icon'], color: isSelected ? Colors.white : Colors.black, size: 24),
                              const SizedBox(height: 8),
                              Text(t['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Text('TRIP DATES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: Colors.black38)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDateTile('Start Date', _startDate, (d) => setState(() => _startDate = d))),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDateTile('End Date', _endDate, (d) => setState(() => _endDate = d))),
                  ],
                ),
                const SizedBox(height: 64),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      disabledBackgroundColor: Colors.black54,
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('GO TO LIST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.white70,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.black),
                    SizedBox(height: 24),
                    Text('AI is packing your bags...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: Colors.black38)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: PackLiteTheme.mutedText2, fontWeight: FontWeight.w500),
            filled: true,
            fillColor: PackLiteTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile(String label, DateTime? date, Function(DateTime) onSelect) {
    return Tappable(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (d != null) onSelect(d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: PackLiteTheme.background, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black38)),
            const SizedBox(height: 4),
            Text(date == null ? 'Select' : '${date.day}/${date.month}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _onContinue() async {
    if (_nameController.text.isNotEmpty && _destController.text.isNotEmpty) {
      setState(() => _isLoading = true);
      
      List<PackItem> initialItems = [];
      
      if (_selectedTemplate == 'AI Magic') {
        final suggestions = await AIService.getPackingSuggestions(_destController.text);
        initialItems = suggestions.map((s) => PackItem(name: s['name'], category: s['category'])).toList();
      } else if (_selectedTemplate == 'Beach') {
        initialItems = [
          PackItem(name: 'Swimwear', category: 'Clothing'),
          PackItem(name: 'Sunscreen', category: 'Toiletries'),
          PackItem(name: 'Towel', category: 'Accessories'),
          PackItem(name: 'Sunglasses', category: 'Accessories'),
          PackItem(name: 'Flip-flops', category: 'Clothing'),
        ];
      } else if (_selectedTemplate == 'Business') {
        initialItems = [
          PackItem(name: 'Suit', category: 'Clothing'),
          PackItem(name: 'Formal Shoes', category: 'Clothing'),
          PackItem(name: 'Laptop', category: 'Electronics'),
          PackItem(name: 'Charger', category: 'Electronics'),
          PackItem(name: 'Notebook', category: 'Documents'),
        ];
      } else if (_selectedTemplate == 'Alpine') {
        initialItems = [
          PackItem(name: 'Hiking Boots', category: 'Clothing'),
          PackItem(name: 'Rain Jacket', category: 'Clothing'),
          PackItem(name: 'Flashlight', category: 'Accessories'),
          PackItem(name: 'Water Bottle', category: 'Accessories'),
          PackItem(name: 'Base Layers', category: 'Clothing'),
        ];
      }

      final trip = Trip(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        destination: _destController.text,
        type: 'Solo',
        date: _startDate ?? DateTime.now(),
        items: initialItems,
        currencyCode: _destController.text.toLowerCase().contains('paris') ? 'EUR' : 'GBP',
        conversionRate: _destController.text.toLowerCase().contains('paris') ? 0.92 : 0.78,
        weatherIcon: _destController.text.toLowerCase().contains('paris') ? '🌤️' : '☁️',
        temperature: '--°',
      );
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => SoloTripScreen(trip: trip)),
      );
    }
  }
}
