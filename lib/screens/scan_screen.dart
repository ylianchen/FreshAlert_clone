import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'receipt_review_screen.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  void _simulateReceiptScan(BuildContext context) {
    // Create some mock food items for testing
    List<FoodItem> mockItems = [
      FoodItem(
        name: 'Milk',
        price: 1.29,
        purchaseDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 7)),
        category: 'dairy',
        storage: 'fridge',
      ),
      FoodItem(
        name: 'Bread',
        price: 2.49,
        purchaseDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 3)),
        category: 'bakery',
        storage: 'pantry',
      ),
      FoodItem(
        name: 'Apples',
        price: 3.99,
        purchaseDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 10)),
        category: 'produce',
        storage: 'fridge',
      ),
    ];

    List<ReceiptItem> mockReceiptItems = [
      ReceiptItem(text: 'Milk', price: 1.29, isItemName: true),
      ReceiptItem(text: 'Bread', price: 2.49, isItemName: true),
      ReceiptItem(text: 'Apples', price: 3.99, isItemName: true),
    ];

    // Navigate to review screen with mock data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptReviewScreen(
          imagePath: '', // Empty for now
          foodItems: mockItems,
          receiptItems: mockReceiptItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              'Camera functionality will be added soon',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'For now, try the demo with mock data',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _simulateReceiptScan(context),
              icon: const Icon(Icons.receipt),
              label: const Text('Try Demo Receipt'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will show you how the receipt\nreview process works',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}