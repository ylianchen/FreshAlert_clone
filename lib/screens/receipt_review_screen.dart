import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_item.dart';

class ReceiptReviewScreen extends StatefulWidget {
  final String imagePath;
  final List<FoodItem> foodItems;
  final List<ReceiptItem> receiptItems;

  const ReceiptReviewScreen({
    super.key,
    required this.imagePath,
    required this.foodItems,
    required this.receiptItems,
  });

  @override
  State<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends State<ReceiptReviewScreen> {
  late List<FoodItem> _editableFoodItems;

  @override
  void initState() {
    super.initState();
    _editableFoodItems = List.from(widget.foodItems);
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) => _EditItemDialog(
        item: _editableFoodItems[index],
        onSave: (updatedItem) {
          setState(() {
            _editableFoodItems[index] = updatedItem;
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _editableFoodItems.removeAt(index);
    });
  }

  void _addManualItem() {
    showDialog(
      context: context,
      builder: (context) => _EditItemDialog(
        item: FoodItem(
          name: '',
          price: 0.0,
          purchaseDate: DateTime.now(),
          expirationDate: DateTime.now().add(const Duration(days: 7)),
          category: 'other',
          storage: 'pantry',
        ),
        onSave: (newItem) {
          setState(() {
            _editableFoodItems.add(newItem);
          });
        },
      ),
    );
  }

  void _saveItems() {
    // TODO: Save items to database
    // For now, just show success message and go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_editableFoodItems.length} items added to inventory'),
        backgroundColor: Colors.green,
      ),
    );

    // Go back to main screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Items'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _addManualItem,
            child: const Text(
              'Add Item',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Receipt image preview
          Container(
            height: 150,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Items list
          Expanded(
            child: _editableFoodItems.isEmpty
                ? const Center(
              child: Text(
                'No items found.\nTap "Add Item" to add manually.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _editableFoodItems.length,
              itemBuilder: (context, index) {
                final item = _editableFoodItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('€${item.price.toStringAsFixed(2)}'),
                        Text('Expires: ${DateFormat('dd.MM.yyyy').format(item.expirationDate)}'),
                        Text('Storage: ${item.storage} • Category: ${item.category}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editItem(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(index),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),

          // Save button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _editableFoodItems.isEmpty ? null : _saveItems,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Save ${_editableFoodItems.length} Items',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditItemDialog extends StatefulWidget {
  final FoodItem item;
  final Function(FoodItem) onSave;

  const _EditItemDialog({
    required this.item,
    required this.onSave,
  });

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late DateTime _expirationDate;
  late String _category;
  late String _storage;

  final List<String> _categories = [
    'dairy', 'meat', 'produce', 'bakery', 'pantry', 'frozen', 'other'
  ];

  final List<String> _storageOptions = [
    'fridge', 'freezer', 'pantry'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(text: widget.item.price.toStringAsFixed(2));
    _expirationDate = widget.item.expirationDate;
    _category = widget.item.category;
    _storage = widget.item.storage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an item name')),
      );
      return;
    }

    final updatedItem = widget.item.copyWith(
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0.0,
      expirationDate: _expirationDate,
      category: _category,
      storage: _storage,
    );

    widget.onSave(updatedItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price (€)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Expiration Date'),
              subtitle: Text(DateFormat('dd.MM.yyyy').format(_expirationDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _storage,
              decoration: const InputDecoration(
                labelText: 'Storage',
                border: OutlineInputBorder(),
              ),
              items: _storageOptions.map((storage) {
                return DropdownMenuItem(
                  value: storage,
                  child: Text(storage.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _storage = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}