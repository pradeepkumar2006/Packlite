import 'package:flutter/material.dart';

enum VaultDocType { passport, ticket, hotel, insurance, identity }

class VaultDocument {
  final String id;
  final String title;
  final String description;
  final VaultDocType type;
  final DateTime dateAdded;
  final String? filePath;

  VaultDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.dateAdded,
    this.filePath,
  });

  IconData get icon {
    switch (type) {
      case VaultDocType.passport: return Icons.badge_outlined;
      case VaultDocType.ticket: return Icons.flight_takeoff_rounded;
      case VaultDocType.hotel: return Icons.hotel_outlined;
      case VaultDocType.insurance: return Icons.security_rounded;
      case VaultDocType.identity: return Icons.fingerprint_rounded;
    }
  }
}
