import 'package:flutter/material.dart';
import '../core/data.dart';
import '../core/theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const ProfileSetupScreen({super.key, required this.onComplete});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _cityCtrl = TextEditingController();
  String _selectedStyle = 'Solo';
  final List<String> _styles = ['Solo', 'Family', 'Luxury', 'Adventure', 'Business'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TRAVELER SETUP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Welcome Explorer!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1)),
          const SizedBox(height: 8),
          Text('Let\'s customize PackLite for your travel style.', style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 16)),
          const SizedBox(height: 32),
          
          const Text('WHERE IS YOUR HOME?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          TextField(
            controller: _cityCtrl,
            decoration: InputDecoration(
              hintText: 'City Name (e.g. London)',
              filled: true,
              fillColor: PackLiteTheme.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 32),
          
          const Text('YOUR TRAVEL STYLE?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _styles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final s = _styles[index];
                final isSel = _selectedStyle == s;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStyle = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSel ? Colors.black : PackLiteTheme.background,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(s, style: TextStyle(color: isSel ? Colors.white : Colors.black, fontWeight: FontWeight.w900, fontSize: 13)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 48),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_cityCtrl.text.isEmpty) return;
                
                final u = TripData.user ?? TravelerProfile();
                u.homeCity = _cityCtrl.text;
                u.travelStyle = _selectedStyle;
                TripData.user = u;
                
                widget.onComplete();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Start Adventure', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
