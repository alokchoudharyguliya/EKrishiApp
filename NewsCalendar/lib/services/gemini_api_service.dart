import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Direct Gemini API Service
/// Communicates directly with Google Gemini API from Flutter app
class GeminiApiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// Test image support by sending image + text to Gemini
  ///
  /// [apiKey] - Google Gemini API key
  /// [imageFile] - Image file to analyze
  /// [prompt] - Text prompt to send with image
  /// [model] - Model name (default: gemini-1.5-flash)
  ///
  /// Returns response from Gemini API
  static Future<Map<String, dynamic>> testImageSupport({
    required String apiKey,
    required File imageFile,
    String prompt = 'Describe what you see in this image in detail.',
    String model = 'gemini-1.5-flash',
  }) async {
    try {
      // Read image file and encode to base64
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      // Determine MIME type from file extension
      final extension = imageFile.path.toLowerCase().split('.').last;
      String mimeType = 'image/jpeg';
      switch (extension) {
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
        default:
          mimeType = 'image/jpeg';
      }

      print('[GeminiApiService] ==========================================');
      print('[GeminiApiService] USING MODEL: $model');
      print('[GeminiApiService] ==========================================');
      print('[GeminiApiService] Image size: ${imageBytes.length} bytes');
      print('[GeminiApiService] MIME type: $mimeType');
      print('[GeminiApiService] Model: $model');

      // Prepare request body
      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inlineData': {'mimeType': mimeType, 'data': imageBase64},
              },
            ],
          },
        ],
      };

      // Make API request
      final url = Uri.parse(
        '$_baseUrl/models/$model:generateContent?key=$apiKey',
      );

      print('[GeminiApiService] Sending request to Gemini API...');
      print(
        '[GeminiApiService] URL: ${url.toString().replaceAll(apiKey, 'API_KEY_HIDDEN')}',
      );

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 60));

      print('[GeminiApiService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Extract text from response
        String? responseText;
        if (responseData['candidates'] != null &&
            responseData['candidates'].isNotEmpty) {
          final candidate = responseData['candidates'][0];
          if (candidate['content'] != null &&
              candidate['content']['parts'] != null &&
              candidate['content']['parts'].isNotEmpty) {
            responseText = candidate['content']['parts'][0]['text'];
          }
        }

        return {
          'success': true,
          'model': model,
          'response': responseText ?? 'No response text found',
          'rawResponse': responseData,
          'supportsImages': true,
        };
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['error']?['message'] ??
            errorData['message'] ??
            'Unknown error';

        // Check if it's an image support error
        final isImageError =
            errorMessage.toLowerCase().contains('image') ||
            errorMessage.toLowerCase().contains('vision') ||
            errorMessage.toLowerCase().contains('multimodal');

        return {
          'success': false,
          'model': model,
          'error': errorMessage,
          'errorCode': response.statusCode,
          'supportsImages': !isImageError,
          'imageSupportError': isImageError,
        };
      }
    } catch (e) {
      print('[GeminiApiService] Error: $e');
      return {'success': false, 'error': e.toString(), 'supportsImages': false};
    }
  }

  /// Build LangChain-style system prompt for crop analysis
  /// Matches the backend cropAnalysisService.js prompt structure
  static String _buildSystemPrompt() {
    return '''You are an expert agricultural AI assistant specializing in crop disease diagnosis, pest identification, and plant health analysis.

Your role:
- Analyze crop images to identify diseases, pests, nutrient deficiencies, or other health issues
- Provide accurate diagnoses based on visual symptoms
- Give actionable treatment recommendations
- Suggest preventive measures
- Provide confidence levels and severity assessments
- At the end add a line that your response might not be directly applicable, please consult with an agricultural expert for detailed treatment recommendations or diagnosis.
- Also add a bounding box of the diseased area in the image with the disease name and confidence written around the bounding box, and return the image with the bounding box drawn on it.
Response Format (CRITICAL - Must follow this JSON-like structure):
{
  "diagnosis": "Clear description of what you see in the image (disease, pest, deficiency, healthy, etc.)",
  "confidence": 0.85, // Number between 0 and 1 (as a float)
  "disease": "Specific disease name if identified (or 'Healthy' or 'Unknown')",
  "severity": "low|moderate|high|critical", // One of these exact values
  "suggestions": [
    "Actionable suggestion 1",
    "Actionable suggestion 2",
    "Actionable suggestion 3"
  ],
  "treatment": [
    {
      "product": "Product name",
      "application": "How to apply it",
      "duration": "Treatment duration"
    }
  ],
  "prevention": [
    "Prevention tip 1",
    "Prevention tip 2"
  ],
  "references": [
    "Resource URL or reference 1",
    "Resource URL or reference 2"
  ]
}

IMPORTANT:
- Always respond in valid JSON format that can be parsed
- confidence must be a number (0.0 to 1.0), not a string
- severity must be exactly one of: "low", "moderate", "high", or "critical"
- All arrays should have at least 2-3 items
- Be specific and actionable in all recommendations
- Use agriculture terminology appropriately''';
  }

  /// Build context text from context map
  static String _buildContextText(Map<String, dynamic>? context) {
    if (context == null) return '';

    final parts = <String>['User provided context for crop analysis:'];

    if (context['imageType'] != null) {
      parts.add('- Image Type: ${context['imageType']}');
    }
    if (context['cropType'] != null) {
      parts.add('- Crop Type: ${context['cropType']}');
    }
    if (context['observedProblem'] != null) {
      parts.add('- Observed Problem: ${context['observedProblem']}');
    }
    if (context['plantAge'] != null) {
      parts.add('- Plant Age: ${context['plantAge']} days');
    }
    if (context['recentWeatherEvent'] != null) {
      final weather = context['recentWeatherEvent'];
      parts.add(
        '- Recent Weather Event: ${weather == true || weather == 'true' ? 'Yes' : 'No'}',
      );
    }

    return parts.join('\n');
  }

  /// Parse JSON response from Gemini, handling code blocks
  static Map<String, dynamic>? _parseJsonResponse(String responseText) {
    try {
      // Try to find JSON in code blocks first
      final jsonBlockMatch = RegExp(
        r'```json\n([\s\S]*?)\n```',
      ).firstMatch(responseText);
      if (jsonBlockMatch != null && jsonBlockMatch.group(1) != null) {
        final jsonString = jsonBlockMatch.group(1)!;
        return json.decode(jsonString) as Map<String, dynamic>;
      }

      // Try to find JSON object in the text
      final jsonObjectMatch = RegExp(r'\{[\s\S]*\}').firstMatch(responseText);
      if (jsonObjectMatch != null && jsonObjectMatch.group(0) != null) {
        final jsonString = jsonObjectMatch.group(0)!;
        return json.decode(jsonString) as Map<String, dynamic>;
      }

      // If no JSON found, return null
      return null;
    } catch (e) {
      print('[GeminiApiService] Error parsing JSON response: $e');
      return null;
    }
  }

  /// Analyze crop image with context using Gemini (LangChain-style prompt)
  ///
  /// [apiKey] - Google Gemini API key
  /// [imageFile] - Crop image file
  /// [context] - Context information (cropType, problem, etc.)
  /// [model] - Model name (default: gemini-1.5-flash)
  ///
  /// Returns structured analysis result matching backend format
  static Future<Map<String, dynamic>> analyzeCropImage({
    required String apiKey,
    required File imageFile,
    Map<String, dynamic>? context,
    String model = 'gemini-1.5-flash',
  }) async {
    try {
      // Build system prompt (LangChain-style)
      final systemPrompt = _buildSystemPrompt();

      // Build context text
      final contextText = _buildContextText(context);

      // Build user prompt
      final userPrompt = '''$contextText

Please analyze the provided crop image and provide a detailed diagnosis following the exact JSON format specified in the system prompt.''';

      // Combine system prompt and user prompt (like LangChain does)
      final fullPrompt = '$systemPrompt\n\n$userPrompt';

      print('[GeminiApiService] ==========================================');
      print('[GeminiApiService] Starting crop analysis with direct API');
      print('[GeminiApiService] Model: $model');
      print('[GeminiApiService] ==========================================');

      // Call testImageSupport with the full prompt
      final result = await testImageSupport(
        apiKey: apiKey,
        imageFile: imageFile,
        prompt: fullPrompt,
        model: model,
      );

      if (result['success'] == true) {
        final responseText = result['response'] as String;
        print('[GeminiApiService] Raw response received, parsing JSON...');

        // Parse JSON response
        final parsedJson = _parseJsonResponse(responseText);

        if (parsedJson != null) {
          // Validate and sanitize parsed data
          final analysis = {
            'diagnosis': parsedJson['diagnosis'] ?? 'No diagnosis available',
            'confidence':
                parsedJson['confidence'] is num
                    ? parsedJson['confidence']
                    : (double.tryParse(
                          parsedJson['confidence']?.toString() ?? '0',
                        ) ??
                        0.0),
            'disease': parsedJson['disease'] ?? 'Unknown',
            'severity':
                [
                      'low',
                      'moderate',
                      'high',
                      'critical',
                    ].contains(parsedJson['severity'])
                    ? parsedJson['severity']
                    : 'unknown',
            'suggestions':
                parsedJson['suggestions'] is List
                    ? List<String>.from(parsedJson['suggestions'])
                    : <String>[],
            'treatment':
                parsedJson['treatment'] is List
                    ? List<Map<String, dynamic>>.from(parsedJson['treatment'])
                    : <Map<String, dynamic>>[],
            'prevention':
                parsedJson['prevention'] is List
                    ? List<String>.from(parsedJson['prevention'])
                    : <String>[],
            'references':
                parsedJson['references'] is List
                    ? List<String>.from(parsedJson['references'])
                    : <String>[],
          };

          print('[GeminiApiService] JSON parsed successfully');
          print('[GeminiApiService] Diagnosis: ${analysis['diagnosis']}');
          print('[GeminiApiService] Confidence: ${analysis['confidence']}');

          return {
            'success': true,
            'analysis': analysis,
            'model': model,
            'provider': 'gemini',
            'rawResponse': responseText,
          };
        } else {
          print('[GeminiApiService] Failed to parse JSON from response');
          return {
            'success': false,
            'error': 'Failed to parse JSON response from Gemini',
            'rawResponse': responseText,
          };
        }
      } else {
        // Return error result
        return {
          'success': false,
          'error': result['error'] ?? 'Unknown error',
          'errorCode': result['errorCode'],
        };
      }
    } catch (e) {
      print('[GeminiApiService] Exception in analyzeCropImage: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
