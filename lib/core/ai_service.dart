import 'dart:convert';
import 'package:http/http.dart' as http;

/// A unified service for all AI-related features in PackLite.
/// Currently uses NVIDIA Llama 3.1 but is architected to be "AI Ready" for Gemini/GPT.
class AIService {
  // Replace with your API key
  static const String _nvidiaApiKey = "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";
  static const String _nvidiaBaseUrl = "https://integrate.api.nvidia.com/v1/chat/completions";

  /// Common method to interact with LLMs
  static Future<String> _getCompletion(String systemPrompt, String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_nvidiaBaseUrl),
        headers: {
          "Authorization": "Bearer $_nvidiaApiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "meta/llama-3.1-8b-instruct",
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": userMessage}
          ],
          "temperature": 0.5,
          "top_p": 1.0,
          "max_tokens": 512, // Reduced tokens for speed
        }),
      ).timeout(const Duration(seconds: 15)); // 15s Timeout

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        String content = decoded['choices'][0]['message']['content'];
        return _cleanJson(content);
      } else {
        throw Exception("AI API Error: ${response.statusCode}");
      }
    } catch (e) {
      print("AI Service Error: $e");
      // Return a minimal valid JSON if it fails so we can use fallbacks
      return "[]"; 
    }
  }

  static String _cleanJson(String content) {
    if (content.contains('```json')) {
      return content.split('```json')[1].split('```')[0].trim();
    } else if (content.contains('```')) {
      return content.split('```')[1].split('```')[0].trim();
    }
    return content.trim();
  }

  /// Get travel insights for a specific location
  static Future<Map<String, dynamic>> getTravelInsights(String location) async {
    const systemPrompt = "You are a premium travel expert. Provide recommendations for a location in STRICT JSON format. Include 'places' (landmarks), 'restaurants' (famous food), and 'hotels' (stays). NO MARKDOWN.";
    try {
      final content = await _getCompletion(systemPrompt, "Explore: $location");
      if (content == "[]") throw Exception("Fallback");
      return jsonDecode(content);
    } catch (e) {
      return {
        "location": location,
        "places": [{"name": "City Center", "reason": "Always a great starting point.", "vibe": "Busy"}],
        "restaurants": [{"name": "Local Bistro", "reason": "Authentic local flavors.", "vibe": "Cozy"}],
        "hotels": [{"name": "Grand Hotel", "reason": "Central and reliable.", "vibe": "Luxury"}]
      };
    }
  }

  /// Get packing suggestions for a specific location
  static Future<List<Map<String, dynamic>>> getPackingSuggestions(String location) async {
    const systemPrompt = "You are a smart packing assistant. Suggest 6 HIGHLY SPECIFIC items. Return STRICT JSON list with 'name', 'category', 'reason'. NO MARKDOWN.";
    try {
      final content = await _getCompletion(systemPrompt, "Packing essentials for: $location");
      final list = List<Map<String, dynamic>>.from(jsonDecode(content));
      if (list.isEmpty) throw Exception("Fallback");
      return list;
    } catch (e) {
      // High Quality Fallback Items
      return [
        {"name": "Power Bank", "category": "Electronics", "reason": "Essential for long travel days."},
        {"name": "Universal Adapter", "category": "Electronics", "reason": "Stay connected everywhere."},
        {"name": "First Aid Kit", "category": "Toiletries", "reason": "Basic safety for every trip."},
        {"name": "Reusable Bottle", "category": "Accessories", "reason": "Eco-friendly and stay hydrated."},
        {"name": "Comfortable Sneakers", "category": "Clothing", "reason": "Perfect for city walks."},
        {"name": "Passport Holder", "category": "Documents", "reason": "Keep essentials safe."}
      ];
    }
  }

  /// Smart chat with PackLite AI
  static Future<String> chat(String message, {String context = ""}) async {
    final systemPrompt = "You are PackLite AI, a premium travel companion. Be concise, helpful, and luxury-focused. Context: $context";
    try {
      final response = await http.post(
        Uri.parse(_nvidiaBaseUrl),
        headers: {
          "Authorization": "Bearer $_nvidiaApiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "meta/llama-3.1-8b-instruct",
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": message}
          ],
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['choices'][0]['message']['content'];
      }
      return "I'm having trouble connecting to my travel brain. Let's try again?";
    } catch (e) {
      return "I'm offline right now, but ready to travel when you are!";
    }
  }
}
