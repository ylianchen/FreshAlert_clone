class FoodItem {
  final int? id;
  final String name;
  final double price;
  final DateTime purchaseDate;
  final DateTime expirationDate;
  final String category;
  final String storage; // fridge, freezer, pantry
  final bool isConsumed;
  final String? brand;
  final double? quantity;
  final String? unit;

  FoodItem({
    this.id,
    required this.name,
    required this.price,
    required this.purchaseDate,
    required this.expirationDate,
    required this.category,
    required this.storage,
    this.isConsumed = false,
    this.brand,
    this.quantity,
    this.unit,
  });

  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'purchase_date': purchaseDate.millisecondsSinceEpoch,
      'expiration_date': expirationDate.millisecondsSinceEpoch,
      'category': category,
      'storage': storage,
      'is_consumed': isConsumed ? 1 : 0,
      'brand': brand,
      'quantity': quantity,
      'unit': unit,
    };
  }

  // Create from map (database)
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchase_date']),
      expirationDate: DateTime.fromMillisecondsSinceEpoch(map['expiration_date']),
      category: map['category'],
      storage: map['storage'],
      isConsumed: map['is_consumed'] == 1,
      brand: map['brand'],
      quantity: map['quantity'],
      unit: map['unit'],
    );
  }

  // Helper methods
  int get daysUntilExpiration {
    final now = DateTime.now();
    return expirationDate.difference(now).inDays;
  }

  bool get isExpired => DateTime.now().isAfter(expirationDate);

  bool get isExpiringSoon => daysUntilExpiration <= 3 && daysUntilExpiration >= 0;

  FoodItem copyWith({
    int? id,
    String? name,
    double? price,
    DateTime? purchaseDate,
    DateTime? expirationDate,
    String? category,
    String? storage,
    bool? isConsumed,
    String? brand,
    double? quantity,
    String? unit,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expirationDate: expirationDate ?? this.expirationDate,
      category: category ?? this.category,
      storage: storage ?? this.storage,
      isConsumed: isConsumed ?? this.isConsumed,
      brand: brand ?? this.brand,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}

// Receipt scanning result
class ReceiptItem {
  final String text;
  final double? price;
  final bool isItemName;
  final bool isPrice;

  ReceiptItem({
    required this.text,
    this.price,
    this.isItemName = false,
    this.isPrice = false,
  });
}