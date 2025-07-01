import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class DeepseekService {
  static const String _apiKey = 'sk-352e33e027014d26bf107ec5b212b0a8';
  static const String _baseUrl = 'https://api.deepseek.com';
  static const String _endpoint = '/v1/chat/completions';

  /// 调用 DeepSeek 接口解析小票 OCR 文本
  static Future<List<FoodItem>> parseReceipt(String ocrText) async {
    final prompt = '''
你是一个智能小票解析器。请分析以下小票文字，识别每项商品，并输出一个 JSON 数组，每项包含字段：
- food_name
- purchase_date（UTC ISO 格式）
- price
- quantity
- freshness_index（初始为1.00）
- deterioration_rate_room
- deterioration_rate_fridge
- deterioration_rate_freezer
- current_storage（初始为"room"）

小票内容如下：
$ocrText
''';

    final response = await http.post(
      Uri.parse('$_baseUrl$_endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'deepseek-chat',
        'messages': [
          {'role': 'system', 'content': '你是一个结构化 JSON 输出的助手，严格输出 JSON 数组。'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.0,
        'max_tokens': 1000,
        'response_format': {'type': 'json_object'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('DeepSeek API 调用失败: ${response.statusCode} ${response.body}');
    }

    final responseData = jsonDecode(response.body);
    final content = responseData['choices'][0]['message']['content'];

    final List<dynamic> parsedList = jsonDecode(content);
    return parsedList.map((e) => FoodItem.fromJson(e)).toList();
  }
}
