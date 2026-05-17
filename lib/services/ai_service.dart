import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class AiService {
  static const String _apiKey = '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';

  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  final CollectionReference _postsRef =
  FirebaseFirestore.instance.collection('posts');

  Future<String> _getPostsContext() async {
    final snapshot = await _postsRef
        .orderBy('postDate', descending: true)
        .limit(100)
        .get();

    final posts = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'name': data['name'] ?? '',
        'location': data['location'] ?? '',
        'description': data['description'] ?? '',
        'tags': List<String>.from(data['tags'] ?? []),
        'rating': data['rating'] ?? 0,
        'reviewCount': data['reviewCount'] ?? 0,
      };
    }).toList();

    return jsonEncode(posts);
  }

  Future<String> _buildSystemPrompt() async {
    final postsContext = await _getPostsContext();

    return '''
You are TravyAssist, a friendly and smart travel assistant for Travixy — a places discovery app.
Your job is to help users discover places they will love based on their preferences.

Here are all the available places in the app:
$postsContext

Your rules:
- Only recommend places from the list above. Never invent places.
- If no places match, say so honestly and ask more about their preferences.
- Ask follow-up questions to learn their taste: budget, atmosphere, type of activity, location preference.
- Remember what the user tells you during the conversation and refine your suggestions.
- Keep responses concise, warm, and conversational.
- When recommending a place, always mention its name, location, rating, and why it matches their taste.
- If the user greets you, introduce yourself briefly and ask what kind of place they are looking for.
''';
  }

  Future<String> sendMessage(List<Map<String, String>> history) async {
    final systemPrompt = await _buildSystemPrompt();

    final List<Map<String, String>> messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => {
        'role': m['role'] == 'user' ? 'user' : 'assistant',
        'content': m['content'] ?? '',
      }),
    ];

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      print('Groq error: ${response.body}');
      final error = jsonDecode(response.body);
      throw Exception('Groq error: ${error['error']['message']}');
    }
  }
}