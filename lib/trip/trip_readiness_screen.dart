import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/data.dart';

class TripReadinessScreen extends StatefulWidget {
  final Trip trip;
  const TripReadinessScreen({super.key, required this.trip});

  @override
  State<TripReadinessScreen> createState() => _TripReadinessScreenState();
}

class _TripReadinessScreenState extends State<TripReadinessScreen> {
  final List<Map<String, dynamic>> _readinessTasks = [
    {'title': 'Download Tickets', 'desc': 'Get offline copies of flight & hotel bookings.', 'icon': Icons.airplane_ticket_outlined, 'isDone': false},
    {'title': 'Visa & Docs', 'desc': 'Check entry requirements and passport validity.', 'icon': Icons.assignment_ind_outlined, 'isDone': true},
    {'title': 'Currency Exchange', 'desc': 'Carry local cash or load travel cards.', 'icon': Icons.account_balance_wallet_outlined, 'isDone': false},
    {'title': 'Emergency Contacts', 'desc': 'Set up your ICE contacts and insurance info.', 'icon': Icons.medical_services_outlined, 'isDone': false},
    {'title': 'Safe Guard', 'desc': 'Upload documents to the Safe Vault.', 'icon': Icons.security_rounded, 'isDone': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Readiness Check', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TRIP JOURNEY STATUS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Colors.blueAccent)),
                const SizedBox(height: 12),
                Text('Heading to ${widget.trip.destination}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 4),
                const Text('Complete these steps for a smooth adventure.', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ..._readinessTasks.map((t) => _buildTaskItem(t)).toList(),
          const SizedBox(height: 48),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> t) {
    return Tappable(
      onTap: () => setState(() => t['isDone'] = !t['isDone']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t['isDone'] ? Colors.black : PackLiteTheme.cardBorder, width: t['isDone'] ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: PackLiteTheme.background, shape: BoxShape.circle),
              child: Icon(t['icon'], size: 20, color: Colors.black),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['title'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text(t['desc'], style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(t['isDone'] ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, color: t['isDone'] ? Colors.black : Colors.black12),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Update Progress', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not now, remind me later', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
        ),
      ],
    );
  }
}
