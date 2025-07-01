import 'package:uuid/uuid.dart';

class FoodItem {
  String id;
  String foodName;
  DateTime purchaseDate;
  double price;
  int quantity;
  double freshnessIndex;
  double deteriorationRateRoom;
  double deteriorationRateFridge;
  double deteriorationRateFreezer;
  String currentStorage;

  FoodItem({
    String? id,
    required this.foodName,
    required this.purchaseDate,
    required this.price,
    required this.quantity,
    this.freshnessIndex = 1.0,
    required this.deteriorationRateRoom,
    required this.deteriorationRateFridge,
    required this.deteriorationRateFreezer,
    this.currentStorage = "room",
  }) : id = id ?? const Uuid().v4();

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] ?? const Uuid().v4(),
      foodName: json['food_name'],
      purchaseDate: DateTime.parse(json['purchase_date']),
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      freshnessIndex: (json['freshness_index'] as num).toDouble(),
      deteriorationRateRoom: (json['deterioration_rate_room'] as num).toDouble(),
      deteriorationRateFridge: (json['deterioration_rate_fridge'] as num).toDouble(),
      deteriorationRateFreezer: (json['deterioration_rate_freezer'] as num).toDouble(),
      currentStorage: json['current_storage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food_name': foodName,
      'purchase_date': purchaseDate.toUtc().toIso8601String(),
      'price': price,
      'quantity': quantity,
      'freshness_index': freshnessIndex,
      'deterioration_rate_room': deteriorationRateRoom,
      'deterioration_rate_fridge': deteriorationRateFridge,
      'deterioration_rate_freezer': deteriorationRateFreezer,
      'current_storage': currentStorage,
    };
  }
}
