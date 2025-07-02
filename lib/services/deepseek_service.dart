import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/food_item.dart';

class DeepseekService {
  static const String _apiKey = 'sk-352e33e027014d26bf107ec5b212b0a8'; // Replace with your actual key
  static const String _endpoint = 'https://api.deepseek.com/v1/chat/completions';

  static Future<List<FoodItem>> parseReceipt(String receiptText) async {
    const productList = [
      "Milk", "Eggs", "Bread", "Banana", "Chicken", "Apple", "Lettuce", "Yogurt",
      "Cheese", "Frozen Pizza", "Pork", "Beef", "Fish", "Carrots", "Strawberries",
      "Grapes", "Tomatoes", "Cucumber", "Orange", "Butter", "Ice Cream", "Shrimp",
      "Salmon", "Ham", "Hot Dog", "Tofu", "Spinach", "Mushrooms", "Corn", "Peach",
      "Pear", "Blueberries", "Cabbage", "Zucchini", "Avocado", "Sausage", "Broccoli",
      "Green Beans", "Watermelon", "Onion", "Potato", "Garlic", "Rice", "Pasta",
      "Flour", "Sugar", "Salt", "Cereal", "Olive Oil", "Jam"
    ];

    final prompt = '''
You are a helpful assistant. Extract a list of food items from the receipt text below.

For each item, return:
- foodName: The name as shown on the receipt.
- item: Match one item from the list below that best represents the product.
- price: Price in float.
- quantity: Integer quantity.
- purchaseTime: Purchase time in UTC format (e.g. "2025-07-01T10:30Z") based on receipt time and location.
- deteriorationRateRoom: Estimated freshness drop rate per hour at room temperature (float).
- deteriorationRateFridge: Estimated freshness drop rate per hour in fridge (float).
- deteriorationRateFreezer: Estimated freshness drop rate per hour in freezer (float).

Use this item list for matching: ${productList.join(", ")}

Return a JSON array, no explanation.

Receipt:
$receiptText
''';

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.4
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final raw = result['choices'][0]['message']['content'];
        final cleaned = raw
            .replaceAll(RegExp(r'```json'), '')
            .replaceAll(RegExp(r'```'), '')
            .trim();

        final List<dynamic> jsonList = jsonDecode(cleaned);

        return jsonList.map((json) {
          final foodItem = FoodItem.fromJson(json);
          foodItem.id = const Uuid().v4();
          foodItem.freshnessIndex = 1.0;
          foodItem.currentStorage = 'room';
          return foodItem;
        }).toList();
      } else {
        print('❌ DeepSeek API error: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Failed to parse receipt: $e');
      return [];
    }
  }
}
