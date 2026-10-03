import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:untitled/features/meal_plan/domain/entities/meal.dart';
import 'package:untitled/features/profile/domain/entities/user_profile.dart';
import 'package:untitled/features/meal_plan/data/models/meal_model.dart';
import 'package:untitled/core/constants/api_config.dart';

abstract class MealRemoteDataSource {
  Future<List<MealModel>> generateMealPlan({
    required UserProfile profile,
    required MealTarget dailyTarget,
  });

  Future<String> getOrGenerateImage(Meal meal);
}

class MealRemoteDataSourceImpl implements MealRemoteDataSource {
  final http.Client client;

  MealRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MealModel>> generateMealPlan({
    required UserProfile profile,
    required MealTarget dailyTarget,
  }) async {
    final prompt = _buildPrompt(profile, dailyTarget);

    final response = await client.post(
      Uri.parse(ApiConfig.geminiEndpoint),
      headers: ApiConfig.geminiHeaders,
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'thinkingConfig': {'thinkingLevel': 'low'},
          'responseMimeType': 'application/json',
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final rawText = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;

    if (rawText == null) {
      throw Exception('Empty response from Gemini');
    }

    final cleaned = rawText.replaceAll(RegExp(r'```json|```'), '').trim();
    final parsed = jsonDecode(cleaned);
    final mealsJson = parsed['meals'] as List;

    return mealsJson.map((m) => MealModel.fromJson(m)).toList();
  }

  @override
  Future<String> getOrGenerateImage(Meal meal) async {
    final cachedPath = await _cachedImagePath(meal.cacheKey);
    final file = File(cachedPath);

    if (await file.exists()) {
      return cachedPath;
    }

    final bytes = await _generateImageBytes(meal);
    await file.writeAsBytes(bytes);
    return cachedPath;
  }

  Future<String> _cachedImagePath(String cacheKey) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/meal_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return '${imagesDir.path}/$cacheKey.png';
  }

  Future<List<int>> _generateImageBytes(Meal meal) async {
    final prompt = 'Professional food photography of ${meal.name}: ${meal.description}. '
        'Top-down or 45-degree angle, natural lighting, appetizing plating, '
        'shallow depth of field, restaurant-quality presentation, '
        '${meal.cuisineTag} cuisine style. No text or watermarks in the image.';

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'responseModalities': ['TEXT', 'IMAGE'],
      },
    });

    const maxAttempts = 4;
    http.Response? response;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      response = await client.post(
        Uri.parse(ApiConfig.imageEndpoint),
        headers: ApiConfig.geminiHeaders,
        body: body,
      );

      if (response.statusCode == 200) break;

      final isRetryable = response.statusCode == 503 || response.statusCode == 429;

      if (!isRetryable || attempt == maxAttempts) {
        throw Exception('Image API error ${response.statusCode} after $attempt attempt(s): ${response.body}');
      }

      final delayMs = (1000 * (1 << (attempt - 1))) + (100 * attempt);
      await Future.delayed(Duration(milliseconds: delayMs));
    }

    final data = jsonDecode(response!.body);
    final candidate = data['candidates']?[0];

    if (candidate == null) {
      final blockReason = data['promptFeedback']?['blockReason'];
      throw Exception(blockReason != null ? 'Prompt blocked: $blockReason' : 'No candidates returned');
    }

    final parts = candidate['content']?['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      throw Exception('No content in response');
    }

    for (final part in parts) {
      final inlineData = part['inlineData'] ?? part['inline_data'];
      if (inlineData != null && inlineData['data'] != null) {
        return base64Decode(inlineData['data']);
      }
    }

    throw Exception('Model responded but included no image part');
  }

  String _buildPrompt(UserProfile p, MealTarget target) {
    final allergyLine = p.allergies.isEmpty ? 'None specified' : p.allergies.join(', ');

    return '''
You are a nutrition and recipe assistant. Generate ${p.mealsPerDay} meals for
one full day for a real person with the following context:

- Country / cuisine style to draw from: ${p.country}
- Eating preference: ${p.eatingPreference.name}
- Allergies / ingredients to strictly avoid: $allergyLine
- Goal: ${p.goal.name} weight
- Daily nutrition target: ${target.calories} kcal total, ${target.proteinG}g protein, ${target.carbsG}g carbs, ${target.fatG}g fat

Requirements:
- Distribute the daily target sensibly across ${p.mealsPerDay} meals (each meal's calories/macros should roughly sum to the daily target).
- Use ingredients realistically available in ${p.country}.
- Respect the eating preference and allergies strictly — do not include excluded ingredients under any circumstance.
- Keep instructions practical (5-8 steps, home-cookable).
- Vary the meals (do not repeat similar dishes across the day).

Return ONLY valid JSON matching this exact schema, with no markdown fences and no extra commentary:
{
  "meals": [
    {
      "name": "string",
      "description": "one sentence, appetizing but factual",
      "cuisineTag": "string, e.g. Pakistani, Italian, Mexican",
      "calories": number,
      "macros": {"proteinG": number, "carbsG": number, "fatG": number},
      "ingredients": [{"name": "string", "quantity": "string with unit"}],
      "instructions": ["step 1", "step 2"]
    }
  ]
}
''';
  }
}
