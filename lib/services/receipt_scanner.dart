import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/food_item.dart';

class ReceiptScannerService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  // List of common food categories for classification
  static const Map<String, List<String>> _foodCategories = {
    'dairy': ['milk', 'cheese', 'yogurt', 'butter', 'cream'],
    'meat': ['chicken', 'beef', 'pork', 'turkey', 'salmon', 'fish'],
    'produce': ['apple', 'banana', 'orange', 'lettuce', 'tomato', 'carrot', 'potato'],
    'bakery': ['bread', 'bagel', 'muffin', 'cake', 'pastry'],
    'pantry': ['rice', 'pasta', 'beans', 'cereal', 'flour', 'sugar'],
    'frozen': ['ice cream', 'frozen', 'pizza'],
  };

  // Common German grocery store chains (for validation)
  static const List<String> _germanStores = [
    'REWE', 'EDEKA', 'LIDL', 'ALDI', 'NETTO', 'PENNY', 'KAUFLAND'
  ];

  Future<List<ReceiptItem>> scanReceipt(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      List<ReceiptItem> items = [];

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String text = line.text.trim();

          // Skip empty lines or very short text
          if (text.length < 2) continue;

          // Try to extract price from the line
          double? price = _extractPrice(text);

          // Determine if this looks like an item name
          bool isItemName = _isLikelyItemName(text);

          // Determine if this is a price line
          bool isPrice = price != null && !isItemName;

          items.add(ReceiptItem(
            text: text,
            price: price,
            isItemName: isItemName,
            isPrice: isPrice,
          ));
        }
      }

      return _processReceiptItems(items);
    } catch (e) {
      print('Error scanning receipt: $e');
      return [];
    }
  }

  double? _extractPrice(String text) {
    // Common German price patterns
    final pricePatterns = [
      RegExp(r'(\d+[,\.]\d{2})\s*€?'), // 1,99€ or 1.99€
      RegExp(r'€\s*(\d+[,\.]\d{2})'), // € 1,99
      RegExp(r'(\d+[,\.]\d{2})\s*EUR'), // 1,99 EUR
    ];

    for (RegExp pattern in pricePatterns) {
      Match? match = pattern.firstMatch(text);
      if (match != null) {
        String priceStr = match.group(1)!;
        // Convert German decimal format to double
        priceStr = priceStr.replaceAll(',', '.');
        return double.tryParse(priceStr);
      }
    }
    return null;
  }

  bool _isLikelyItemName(String text) {
    // Skip if it's clearly not an item
    if (text.length > 50) return false; // Too long
    if (RegExp(r'^\d+$').hasMatch(text)) return false; // Just numbers
    if (text.contains('TOTAL') || text.contains('SUMME')) return false;
    if (text.contains('DATUM') || text.contains('DATE')) return false;
    if (text.contains('UHRZEIT') || text.contains('TIME')) return false;
    if (_germanStores.any((store) => text.toUpperCase().contains(store))) return false;

    // Positive indicators
    if (_isKnownFoodItem(text)) return true;
    if (text.split(' ').length <= 4 && text.length >= 3) return true; // Reasonable length

    return false;
  }

  bool _isKnownFoodItem(String text) {
    String lowerText = text.toLowerCase();
    for (List<String> category in _foodCategories.values) {
      for (String item in category) {
        if (lowerText.contains(item.toLowerCase())) {
          return true;
        }
      }
    }
    return false;
  }

  String _categorizeItem(String itemName) {
    String lowerName = itemName.toLowerCase();

    for (String category in _foodCategories.keys) {
      for (String keyword in _foodCategories[category]!) {
        if (lowerName.contains(keyword.toLowerCase())) {
          return category;
        }
      }
    }

    return 'other'; // Default category
  }

  String _determineStorage(String category) {
    switch (category) {
      case 'dairy':
      case 'meat':
      case 'produce':
        return 'fridge';
      case 'frozen':
        return 'freezer';
      case 'pantry':
      case 'bakery':
      default:
        return 'pantry';
    }
  }

  DateTime _estimateExpirationDate(String category) {
    DateTime now = DateTime.now();

    switch (category) {
      case 'dairy':
        return now.add(const Duration(days: 7));
      case 'meat':
        return now.add(const Duration(days: 3));
      case 'produce':
        return now.add(const Duration(days: 5));
      case 'bakery':
        return now.add(const Duration(days: 3));
      case 'frozen':
        return now.add(const Duration(days: 30));
      case 'pantry':
      default:
        return now.add(const Duration(days: 30));
    }
  }

  List<ReceiptItem> _processReceiptItems(List<ReceiptItem> rawItems) {
    List<ReceiptItem> processedItems = [];

    // Try to match items with prices
    for (int i = 0; i < rawItems.length; i++) {
      ReceiptItem item = rawItems[i];

      if (item.isItemName) {
        // Look for a price in the same line or nearby lines
        double? itemPrice = item.price;

        if (itemPrice == null) {
          // Check next few lines for a price
          for (int j = i + 1; j < i + 3 && j < rawItems.length; j++) {
            if (rawItems[j].price != null) {
              itemPrice = rawItems[j].price;
              break;
            }
          }
        }

        processedItems.add(ReceiptItem(
          text: item.text,
          price: itemPrice,
          isItemName: true,
          isPrice: false,
        ));
      }
    }

    return processedItems;
  }

  List<FoodItem> convertToFoodItems(List<ReceiptItem> receiptItems) {
    List<FoodItem> foodItems = [];
    DateTime purchaseDate = DateTime.now();

    for (ReceiptItem item in receiptItems) {
      if (item.isItemName) {
        String category = _categorizeItem(item.text);
        String storage = _determineStorage(category);
        DateTime expirationDate = _estimateExpirationDate(category);

        foodItems.add(FoodItem(
          name: item.text,
          price: item.price ?? 0.0,
          purchaseDate: purchaseDate,
          expirationDate: expirationDate,
          category: category,
          storage: storage,
        ));
      }
    }

    return foodItems;
  }

  void dispose() {
    _textRecognizer.close();
  }
}