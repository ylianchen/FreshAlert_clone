class FoodItem {
  String id;
  String foodName;
  String item;
  double price;
  int quantity;
  String purchaseTime;
  double freshnessIndex;
  double deteriorationRateRoom;
  double deteriorationRateFridge;
  double deteriorationRateFreezer;
  String currentStorage;

  FoodItem({
    required this.id,
    required this.foodName,
    required this.item,
    required this.price,
    required this.quantity,
    required this.purchaseTime,
    required this.freshnessIndex,
    required this.deteriorationRateRoom,
    required this.deteriorationRateFridge,
    required this.deteriorationRateFreezer,
    required this.currentStorage,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: '',
      foodName: json['foodName'],
      item: json['item'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      purchaseTime: json['purchaseTime'],
      freshnessIndex: 1.0,
      deteriorationRateRoom: (json['deteriorationRateRoom'] as num).toDouble(),
      deteriorationRateFridge: (json['deteriorationRateFridge'] as num).toDouble(),
      deteriorationRateFreezer: (json['deteriorationRateFreezer'] as num).toDouble(),
      currentStorage: 'room',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'item': item,
      'price': price,
      'quantity': quantity,
      'purchaseTime': purchaseTime,
      'freshnessIndex': freshnessIndex,
      'deteriorationRateRoom': deteriorationRateRoom,
      'deteriorationRateFridge': deteriorationRateFridge,
      'deteriorationRateFreezer': deteriorationRateFreezer,
      'currentStorage': currentStorage,
    };
  }
}
