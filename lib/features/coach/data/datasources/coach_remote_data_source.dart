import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:untitled/core/constants/api_config.dart';
import 'package:untitled/features/coach/domain/entities/chat_message.dart';

abstract class CoachRemoteDataSource {
  Future<String> sendMessage({
    required String systemPrompt,
    required List<ChatMessage> history,
  });
}

class CoachRemoteDataSourceImpl implements CoachRemoteDataSource {
  final http.Client client;

  CoachRemoteDataSourceImpl({required this.client});

  @override
  Future<String> sendMessage({
    required String systemPrompt,
    required List<ChatMessage> history,
  }) async {
    final response = await client.post(
      Uri.parse(ApiConfig.geminiEndpoint),
      headers: ApiConfig.geminiHeaders,
      body: jsonEncode({
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt}
          ],
        },
        'contents': history
            .map((m) => {
                  'role': m.role == ChatRole.user ? 'user' : 'model',
                  'parts': [
                    {'text': m.text}
                  ],
                })
            .toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final candidate = data['candidates']?[0];
    if (candidate == null) {
      final blockReason = data['promptFeedback']?['blockReason'];
      throw Exception(blockReason != null ? 'Prompt blocked: $blockReason' : 'No response from coach');
    }

    final text = candidate['content']?['parts']?[0]?['text'] as String?;
    if (text == null) {
      throw Exception('Empty response from coach');
    }
    return text.trim();
  }
}
