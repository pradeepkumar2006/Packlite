import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'vault_model.dart';

class FullVaultScreen extends StatefulWidget {
  const FullVaultScreen({super.key});

  @override
  State<FullVaultScreen> createState() => _FullVaultScreenState();
}

class _FullVaultScreenState extends State<FullVaultScreen> {
  final List<VaultDocument> _allDocs = [
    VaultDocument(id: '1', title: 'Passport Copy', description: 'Expires 2030', type: VaultDocType.passport, dateAdded: DateTime.now()),
    VaultDocument(id: '2', title: 'Flight to Bali', description: 'QR Code Ready', type: VaultDocType.ticket, dateAdded: DateTime.now()),
    VaultDocument(id: '3', title: 'Hotel Voucher', description: 'Confirmed', type: VaultDocType.hotel, dateAdded: DateTime.now()),
    VaultDocument(id: '4', title: 'Travel Insurance', description: 'Policy #12345', type: VaultDocType.insurance, dateAdded: DateTime.now()),
  ];

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredDocs = _allDocs.where((doc) => doc.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
        ),
        title: const Text('Travel Vault', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded, color: Colors.black)),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: PackLiteTheme.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search documents...',
                  hintStyle: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w700),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search_rounded, color: Colors.black54),
                ),
              ),
            ),
          ),

          // Categories Horizontal
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildCategoryChip('All', true),
                _buildCategoryChip('Identity', false),
                _buildCategoryChip('Tickets', false),
                _buildCategoryChip('Finance', false),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Grid View
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                return _buildGridDocCard(context, filteredDocs[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDocDialog(context),
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: isSelected ? null : Border.all(color: PackLiteTheme.cardBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildGridDocCard(BuildContext context, VaultDocument doc) {
    return Tappable(
      onTap: () {
        // Use preview from vault_screen
        // In a real app we'd share this logic
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: PackLiteTheme.cardBorder, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: PackLiteTheme.background, borderRadius: BorderRadius.circular(12)),
              child: Icon(doc.icon, color: Colors.black, size: 24),
            ),
            const Spacer(),
            Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(doc.description, style: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w700, fontSize: 10)),
            const SizedBox(height: 8),
            Row(
              children: [
                 Icon(Icons.lock_rounded, size: 10, color: PackLiteTheme.mutedText),
                 const SizedBox(width: 4),
                 Text('SECURE', style: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w900, fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDocDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ADD DOCUMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5, color: Colors.black45)),
            const SizedBox(height: 8),
            const Text('Choose source', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
            const SizedBox(height: 24),
            _buildSourceOption(Icons.picture_as_pdf_rounded, 'Upload PDF File', 'Pick from phone storage'),
            const SizedBox(height: 12),
            _buildSourceOption(Icons.camera_rounded, 'Camera Scan', 'Point and capture document'),
            const SizedBox(height: 12),
            _buildSourceOption(Icons.auto_awesome_rounded, 'AI Smart Scan', 'Auto-extract info from documents'),
            const SizedBox(height: 12),
            _buildSourceOption(Icons.image_rounded, 'Photo Gallery', 'Pick an existing image'),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PackLiteTheme.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                Text(sub, style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
    );
  }
}
