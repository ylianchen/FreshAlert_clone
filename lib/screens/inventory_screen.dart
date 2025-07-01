import 'package:flutter/material.dart';
import '../models/food_item.dart';

class InventoryScreen extends StatelessWidget {
  final List<FoodItem> items;
  const InventoryScreen({super.key, this.items = const []});

  @override
  Widget build(BuildContext context) {
    final visibleItems = items.where((item) =>
      (item.foodName.isNotEmpty)
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: visibleItems.isEmpty
            ? const SizedBox.shrink()
            : ListView.builder(
                itemCount: visibleItems.length,
                itemBuilder: (context, idx) {
                  final item = visibleItems[idx];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.foodName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('购买日期: ${item.purchaseDate.toLocal().toString().split(' ')[0]}'),

                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
