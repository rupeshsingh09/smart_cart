import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// Extracts relevant search keywords/categories from a natural language query.
  /// Returns a comma-separated string of keywords, or an empty string on failure.
  Future<String> getSearchKeywords(String query) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_OPENAI_API_KEY_HERE') {
      throw Exception('OpenAI API Key is missing or invalid.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {
          'role': 'system',
          'content': 'You are an e-commerce search assistant. Given a user query, return ONLY a comma-separated list of relevant product keywords or categories that could match it in a product database. Do not include any conversational text or explanations. Examples:\nInput: "best phone under 20000"\nOutput: "mobile, electronics, budget phone, smartphone"\nInput: "cheap shoes"\nOutput: "shoes, footwear, sneakers, cheap"'
        },
        {
          'role': 'user',
          'content': query,
        }
      ],
      'temperature': 0.3,
      'max_tokens': 50,
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        return content.trim();
      } else {
        throw Exception('OpenAI API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to communicate with OpenAI: $e');
    }
  }
}
