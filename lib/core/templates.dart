
import 'data.dart';

class PackingTemplate {
  final String id;
  final String name;
  final String description;
  final String category; // 'Adventure', 'Business', 'Leisure', 'Beach', 'City'
  final List<String> items;
  final String? icon;

  PackingTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.items,
    this.icon,
  });
}

class TemplateData {
  static List<PackingTemplate> allTemplates = [
    // ADVENTURE
    PackingTemplate(
      id: 'adv1',
      name: 'High Altitude Trek',
      description: 'Optimized for 3000m+ climbs with thermal regulation.',
      category: 'Adventure',
      items: ['Hiking Boots', 'Thermal Base Layer', 'Oxygen Tank', 'Trekking Poles', 'Rain Shell', 'First Aid Kit'],
      icon: '🏔️',
    ),
    PackingTemplate(
      id: 'adv2',
      name: 'Sahara Expedition',
      description: 'Focus on hydration and sun protection in desert climates.',
      category: 'Adventure',
      items: ['Loose Linen Shirt', 'Sun Hat', 'Hydration Pack', 'Dust Mask', 'Light Scarf', 'Compass'],
      icon: '🏜️',
    ),
    PackingTemplate(
      id: 'adv3',
      name: 'Tropical Rainforest',
      description: 'Quick-dry gear and insect protection.',
      category: 'Adventure',
      items: ['Mosquito Net', 'Waterproof Bag', 'Dry-Fit T-Shirts', 'Leech Socks', 'Anti-Fungal Cream'],
      icon: '🌿',
    ),

    // BEACH
    PackingTemplate(
      id: 'bch1',
      name: 'Maldives Luxury',
      description: 'Elegant resort wear and snorkeling gear.',
      category: 'Beach',
      items: ['Swim trunks', 'Snorkel Mask', 'Linen Shorts', 'Sunscreen SPF 50', 'Flip Flops', 'Sunglasses'],
      icon: '🏖️',
    ),
    PackingTemplate(
      id: 'bch2',
      name: 'Bali Surf Trip',
      description: 'Rash guards and beach essentials for surf lovers.',
      category: 'Beach',
      items: ['Surfboard Wax', 'Rash Guard', 'Dry Bag', 'Beach Towel', 'GoPro', 'Waterproof Watch'],
      icon: '🏄',
    ),

    // BUSINESS
    PackingTemplate(
      id: 'biz1',
      name: 'Tech Conference',
      description: 'Gadget-heavy list for the modern professional.',
      category: 'Business',
      items: ['Laptop', 'Power Bank', 'Conference Badge', 'Noise Cancelling Headphones', 'Business Cards', 'Comfortable Blazers'],
      icon: '💻',
    ),
    PackingTemplate(
      id: 'biz2',
      name: 'Executive Board',
      description: 'Formal attire and presentation tools.',
      category: 'Business',
      items: ['Suit', 'Silk Tie', 'Dress Shoes', 'Cufflinks', 'Presentation Clicker', 'Leather Portfolio'],
      icon: '👔',
    ),

    // CITY
    PackingTemplate(
      id: 'cty1',
      name: 'Paris Fashion Week',
      description: 'High-end stylish pieces for the fashion capital.',
      category: 'City',
      items: ['Trench Coat', 'Beret', 'Designer Loafers', 'Silk Scarf', 'Portable Camera', 'Umbrella'],
      icon: '🗼',
    ),
    PackingTemplate(
      id: 'cty2',
      name: 'Tokyo Nightlife',
      description: 'Neon-ready streetwear and transit cards.',
      category: 'City',
      items: ['Streetwear Hoodie', 'Comfortable Walking Shoes', 'Suica Card', 'Portable Wi-Fi', 'Pocket Translator'],
      icon: '🏮',
    ),

    // WINTER
    PackingTemplate(
      id: 'wnt1',
      name: 'Iceland Aurora',
      description: 'Multi-layer system for freezing temperatures.',
      category: 'Winter',
      items: ['Parka', 'Woolen Socks', 'Tripod', 'Gloves', 'Beanie', 'Heat Packs'],
      icon: '❄️',
    ),
  ];

  static List<PackingTemplate> getByCategory(String cat) {
    if (cat == 'All') return allTemplates;
    return allTemplates.where((t) => t.category == cat).toList();
  }
}
