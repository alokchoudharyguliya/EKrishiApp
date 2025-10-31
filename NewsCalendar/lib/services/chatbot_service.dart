import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newscalendar/constants/constants.dart';
import 'package:newscalendar/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ChatbotService {
  static const String baseEndpoint = '/api/chatbot';

  /// Send a message to the chatbot
  /// Returns the response from the AI
  static Future<Map<String, dynamic>> sendMessage(
    BuildContext context,
    String message, {
    String? sessionId,
  }) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) {
        throw Exception('Authentication required. Please log in.');
      }

      final url = Uri.parse('$BASE_URL$baseEndpoint/message');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
          'sessionId': sessionId, // null for new conversation
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your connection.');
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'response': responseData['response'] as String,
          'sessionId': responseData['sessionId'] as String,
          'provider': responseData['provider'] as String?,
        };
      } else {
        final errorMessage = responseData['message'] as String? ?? 
                           'Failed to get response from chatbot';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Get conversation history
  static Future<List<Map<String, dynamic>>> getHistory(
    BuildContext context,
    String sessionId,
  ) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) {
        throw Exception('Authentication required. Please log in.');
      }

      final url = Uri.parse('$BASE_URL$baseEndpoint/history?sessionId=$sessionId');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Please check your connection.');
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        final messages = responseData['messages'] as List<dynamic>;
        return messages.map((msg) => msg as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load conversation history');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Delete conversation history
  static Future<void> deleteHistory(
    BuildContext context,
    String sessionId,
  ) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAuthToken();

      if (token == null) {
        throw Exception('Authentication required. Please log in.');
      }

      final url = Uri.parse('$BASE_URL$baseEndpoint/history/$sessionId');
      
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout. Please check your connection.');
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        return;
      } else {
        throw Exception('Failed to delete conversation history');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}

