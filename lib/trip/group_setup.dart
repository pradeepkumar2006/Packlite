import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/data.dart';
import 'group_trip.dart';

class GroupSetupScreen extends StatefulWidget {
  const GroupSetupScreen({super.key});

  @override
  State<GroupSetupScreen> createState() => _GroupSetupScreenState();
}

class _GroupSetupScreenState extends State<GroupSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  DateTime? _startDate;
  String _selectedTemplate = 'Standard';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _templates = [
    {'name': 'Standard', 'icon': Icons.group_rounded, 'desc': 'General group trip'},
    {'name': 'Family', 'icon': Icons.family_restroom_rounded, 'desc': 'Safe & Relaxing'},
    {'name': 'Adventure', 'icon': Icons.explore_rounded, 'desc': 'Hiking & Outdoors'},
    {'name': 'Festival', 'icon': Icons.music_note_rounded, 'desc': 'Party & Events'},
    {'name': 'Retreat', 'icon': Icons.spa_rounded, 'desc': 'Wellness & Peace'},
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
        title: const Text('New Group Trip', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The more the merrier.', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1)),
            const SizedBox(height: 8),
            Text('Set up your collective journey details.', style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 48),
            _buildField('Trip Title', 'e.g. Goa 2024 Bash', _nameController),
            const SizedBox(height: 24),
            _buildField('Where to?', 'e.g. North Goa, India', _destController),
            const SizedBox(height: 24),
            const Text('TRIP ARCHETYPE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: Colors.black38)),
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
            const Text('START DATE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: Colors.black38)),
            const SizedBox(height: 12),
            Tappable(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _startDate = d);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: PackLiteTheme.background, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18),
                    const SizedBox(width: 16),
                    Text(_startDate == null ? 'Select Trip Start Date' : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
              ),
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
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text('CREATE GROUP TRIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
          ],
        ),
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

  void _onContinue() {
    if (_nameController.text.isNotEmpty && _destController.text.isNotEmpty) {
      final trip = Trip(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        destination: _destController.text,
        type: 'Group',
        date: _startDate ?? DateTime.now(),
        items: [],
        members: ['You'], 
        currencyCode: 'USD',
        conversionRate: 1.0,
        weatherIcon: '🌤️',
        temperature: '--°',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => GroupTripScreen(trip: trip)),
      );
    }
  }
}
