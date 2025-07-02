import 'package:flutter/material.dart';
import '../models/food_item.dart';

class FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const FoodItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.green.shade100 : Colors.white,
      elevation: isSelected ? 6 : 2,
      shape: RoundedRectangleBorder(
        side: isSelected
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title: food name
              Text(
                item.foodName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 4),

              // Item matched category
              Text(
                'Item: ${item.item}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),

              const SizedBox(height: 4),

              // Purchase date
              Text(
                'Purchase Date: ${item.purchaseTime.substring(0, 10)}',
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 4),

              // Freshness index
              Text(
                'Freshness: ${item.freshnessIndex.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 4),

              // Current storage
              Text(
                'Storage: ${item.currentStorage}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
