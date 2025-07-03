import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/food_item.dart';
import '../services/ocr_service.dart';
import '../services/deepseek_service.dart';
import '../services/firebase_service.dart';
import '../widgets/food_item_card.dart';

enum ScanState { idle, processing, scanned }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  ScanState scanState = ScanState.idle;
  List<FoodItem> scannedItems = [];
  Set<String> selectedIds = {};
  File? imageFile;

  Future<void> handleImageInput(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        scanState = ScanState.processing;
        imageFile = File(picked.path);
      });

      try {
        final text = await OcrService.recognizeText(imageFile!);
        print('📝 OCR Text Result:\n$text'); // 👈 OCR 调试输出

        final items = await DeepseekService.parseReceipt(text);
        print('✅ DeepSeek 返回 ${items.length} 个食品项'); // 👈 DeepSeek 调试输出

        for (var item in items) {
          print('- ${item.foodName}, \$${item.price}, ${item.quantity}x, ${item.currentStorage}');
        }

        setState(() {
          scannedItems = items;
          selectedIds.clear();
          scanState = ScanState.scanned;
        });
      } catch (e) {
        print('❌ 解析失败: $e');
        setState(() => scanState = ScanState.idle);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('解析失败: $e')),
        );
      }
    }
  }


  void toggleSelection(String id) {
    setState(() {
      selectedIds.contains(id) ? selectedIds.remove(id) : selectedIds.add(id);
    });
  }

  Future<void> uploadSelectedItems(String storageType) async {
    final selected = scannedItems.where((item) => selectedIds.contains(item.id)).toList();
    for (var item in selected) {
      item.currentStorage = storageType;
      await FirebaseService.uploadFoodItem(item);
    }
    setState(() {
      scannedItems.removeWhere((item) => selectedIds.contains(item.id));
      selectedIds.clear();
    });
  }

  void resetScan() {
    setState(() {
      scanState = ScanState.idle;
      scannedItems.clear();
      selectedIds.clear();
      imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: switch (scanState) {
        ScanState.idle => Stack(
          children: [
            Container(color: Colors.black12),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library, size: 32),
                      onPressed: () => handleImageInput(ImageSource.gallery),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => handleImageInput(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Scan"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ScanState.processing => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Processing receipt…")
            ],
          ),
        ),
        ScanState.scanned => Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: scannedItems.length,
                itemBuilder: (context, index) {
                  final item = scannedItems[index];
                  final selected = selectedIds.contains(item.id);
                  return FoodItemCard(
                    item: item,
                    isSelected: selected,
                    onTap: () => toggleSelection(item.id),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: selectedIds.isEmpty ? null : () => uploadSelectedItems("room"),
                    icon: const Icon(Icons.inventory),
                    label: const Text("Room"),
                  ),
                  ElevatedButton.icon(
                    onPressed: selectedIds.isEmpty ? null : () => uploadSelectedItems("fridge"),
                    icon: const Icon(Icons.kitchen),
                    label: const Text("Fridge"),
                  ),
                  ElevatedButton.icon(
                    onPressed: selectedIds.isEmpty ? null : () => uploadSelectedItems("freezer"),
                    icon: const Icon(Icons.ac_unit),
                    label: const Text("Freezer"),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: resetScan,
              icon: const Icon(Icons.restart_alt),
              label: const Text("Scan Again"),
            ),
          ],
        ),
      },
    );
  }
}
