import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/theme.dart';
import 'vault_model.dart';
import 'full_vault.dart';

class VaultBottomSheet extends StatelessWidget {
  const VaultBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final docs = [
      VaultDocument(
        id: '1',
        title: 'Passport Copy',
        description: 'Expires 2030',
        type: VaultDocType.passport,
        dateAdded: DateTime.now(),
      ),
      VaultDocument(
        id: '2',
        title: 'Flight to Bali',
        description: 'QR Code Ready',
        type: VaultDocType.ticket,
        dateAdded: DateTime.now(),
      ),
      VaultDocument(
        id: '3',
        title: 'Hotel Voucher',
        description: 'Confirmed',
        type: VaultDocType.hotel,
        dateAdded: DateTime.now(),
      ),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Glassmorphism background effect (subtle)
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Icon(Icons.security_rounded, size: 300, color: Colors.black),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TRAVEL VAULT',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.5,
                            color: Colors.black45,
                          ),
                        ),
                        Text(
                          'Quick Access',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Tappable(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PackLiteTheme.background,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Horizontal Documents Scroll
              SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return _buildDocCard(context, docs[index]);
                  },
                ),
              ),

              const Spacer(),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Tappable(
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const FullVaultScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Open Full Vault',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, VaultDocument doc) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PackLiteTheme.cardBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: PackLiteTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(doc.icon, color: Colors.black, size: 24),
          ),
          const Spacer(),
          Text(
            doc.title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            doc.description,
            style: TextStyle(
              color: PackLiteTheme.mutedText,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Tappable(
            onTap: () {
              // Show quick preview
              _showQuickPreview(context, doc);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'VIEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickPreview(BuildContext context, VaultDocument doc) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                      Tappable(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(doc.icon, size: 80, color: Colors.black12),
                        const SizedBox(height: 20),
                        const Text(
                          'DOCUMENT PREVIEW',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.black38),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'This document is encrypted and stored locally. You can access it anytime without internet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
