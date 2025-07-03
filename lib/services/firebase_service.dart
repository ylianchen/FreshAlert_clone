import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> uploadFoodItem(FoodItem item) async {
    await _firestore.collection('food_inventory').doc(item.id).set(item.toJson());
  }
}
