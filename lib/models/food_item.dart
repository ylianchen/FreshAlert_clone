class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String location;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double estimatedValue;
  final bool isExpired;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.purchaseDate,
    required this.expiryDate,
    required this.estimatedValue,
    this.isExpired = false,
  });
}