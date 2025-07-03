import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:freshalert/models/food_item.dart';

class GptService {
  static const String _apiKey = 'sk-zzz-sk-zk2c69eae627e4742d236b9bbc221cf1b4f6862eec0eef22';
  static const String _baseUrl = 'https://api.zhizengzeng.com/v1';

  static Future<List<FoodItem>> parseReceipt(String ocrText) async {
    final url = Uri.parse('$_baseUrl/chat/completions');

    final prompt = '''
你是一个智能小票解析助手，请根据以下小票文字，提取每项商品的信息，返回一个JSON数组，每项包括如下字段：
- food_name: 食品名
- purchase_date: UTC时间格式（你可根据小票中的时间和地址信息判断时区）
- price: 单价，浮点数
- quantity: 数量，整数
- freshness_index: 默认为1.00
- deterioration_rate_room: 室温下每小时新鲜度下降，0.02为正常值
- deterioration_rate_fridge: 冷藏下降速率
- deterioration_rate_freezer: 冷冻下降速率
- current_storage: 默认为 "room"

返回格式严格为JSON数组，不需要多余解释。

小票内容如下：
$ocrText
''';

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': '你是一个智能小票解析助手，擅长从OCR文本中提取结构化食品数据。'
          },
          {
            'role': 'user',
            'content': prompt
          },
        ],
        'temperature': 0.2,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      final items = jsonDecode(content) as List;

      return items.map((item) => FoodItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to call GPT: ${response.body}');
    }
  }
}
