

class PackItem {
  final String name;
  bool isPacked;
  final String category;
  final double? weight; // Estimated weight in grams
  bool needsToBuy;
  String? bagId;

  PackItem({
    required this.name,
    this.isPacked = false,
    required this.category,
    this.weight = 200.0, // Default 200g
    this.needsToBuy = false,
    this.bagId,
  });
}

class Bag {
  final String id;
  final String name;
  final String type; // e.g., 'Backpack', 'Luggage'

  Bag({required this.id, required this.name, required this.type});
}

class ToDoItem {
  final String id;
  String title;
  bool isDone;
  final DateTime? dueDate;

  ToDoItem({required this.id, required this.title, this.isDone = false, this.dueDate});
}

class Expense {
  final String id;
  final String description;
  final double amount;
  final String paidBy; // Name of the member who paid
  final DateTime date;
  final List<String> splitBetween; // Names of members splitting this
  final String? category; // Food, Transport, Stay, etc.

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.date,
    required this.splitBetween,
    this.category,
  });

  double get perPersonAmount => splitBetween.isEmpty ? 0 : amount / splitBetween.length;
}

class Trip {
  final String id;
  String name;
  String destination;
  final String type; // 'Solo' or 'Group'
  final DateTime date;
  final List<PackItem> items;
  final List<Expense> expenses;
  final List<String> members;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? lastPackedAt;

  final String? currencyCode;
  final double? conversionRate;
  final String? weatherIcon;
  final String? temperature;

  final List<Bag> bags;
  final List<ToDoItem> toDoList;

  Trip({
    required this.id,
    required this.name,
    required this.destination,
    required this.type,
    required this.date,
    required this.items,
    List<Expense>? expenses,
    List<String>? members,
    List<Bag>? bags,
    this.isCompleted = false,
    DateTime? createdAt,
    this.lastPackedAt,
    this.currencyCode = 'USD',
    this.conversionRate = 1.0,
    this.weatherIcon = '☀️',
    this.temperature = '--°',
    List<ToDoItem>? toDoList,
  })  : expenses = expenses ?? [],
        members = members ?? ['You'],
        bags = bags ?? [Bag(id: '1', name: 'Backpack', type: 'Backpack'), Bag(id: '2', name: 'Main Luggage', type: 'Luggage')],
        toDoList = toDoList ?? [],
        createdAt = createdAt ?? DateTime.now();

  double get progress => items.isEmpty ? 1.0 : items.where((i) => i.isPacked).length / items.length;
  double get totalWeightKg => items.fold(0.0, (sum, i) => sum + (i.weight ?? 0.0)) / 1000.0;
  double get packedWeightKg => items.where((i) => i.isPacked).fold(0.0, (sum, i) => sum + (i.weight ?? 0.0)) / 1000.0;
  
  double get totalSpent => expenses.fold(0.0, (sum, e) => sum + e.amount);

  int get pendingTasksCount => toDoList.where((t) => !t.isDone).length;
  List<ToDoItem> get todos => toDoList; // Alias for legacy support
}


class TravelerProfile {
  String? name;
  String? email;
  String? photoUrl;
  String? homeCity;
  String? travelStyle;
  List<String> stamps;
  int milesCovered;
  String? iceContactName;
  String? iceContactPhone;
  String? passportNumber;

  TravelerProfile({
    this.name,
    this.email,
    this.photoUrl,
    this.homeCity,
    this.travelStyle = 'Explorer',
    this.stamps = const [],
    this.milesCovered = 0,
    this.iceContactName,
    this.iceContactPhone,
    this.passportNumber,
  });
}

class TripData {
  static List<Trip> trips = [];
  static TravelerProfile? user;
  
  static void addOrUpdateTrip(Trip trip) {
    int index = trips.indexWhere((t) => t.id == trip.id);
    if (index != -1) {
      trips[index] = trip;
    } else {
      trips.add(trip);
    }
  }

  static Trip? get lastActiveTrip {
    if (trips.isEmpty) return null;
    return trips.lastWhere((t) => !t.isCompleted, orElse: () => trips.last);
  }
}
