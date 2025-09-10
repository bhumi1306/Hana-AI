import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../UI/home.dart';
import '../Utility/commons.dart';

class ApiService {

  static Future<String?> getAuthToken() async {
    String token = await getToken();
    return token;
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Save chat history to backend
  static Future<bool> saveChatHistory(List<ChatSession> chatHistory) async {
    try {
      final userId = await getUserId();
      if (userId == null) return false;

      final headers = await getAuthHeaders();
      final body = json.encode({
        'chatHistory': chatHistory.map((session) => session.toJson()).toList(),
      });
      final response = await http.post(
        Uri.parse('$baseUrl/chat-history/$userId'),
        headers: headers,
        body: body,
      );
      debugPrint('chat save response: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error saving chat history: $e');
      return false;
    }
  }

  // Get chat history from backend
  static Future<List<ChatSession>> getChatHistory({int limit = 50, int offset = 0}) async {
    try {
      final userId = await getUserId();
      if (userId == null) return [];

      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat-history/$userId?limit=$limit&offset=$offset'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> chatHistoryData = data['data']['chatHistory'];
        debugPrint('chat history response: ${response.body}');
        return chatHistoryData.map((item) => ChatSession.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      return [];
    }
  }

  // Get specific chat session
  static Future<ChatSession?> getChatSession(String sessionId) async {
    try {
      final userId = await getUserId();
      if (userId == null) return null;

      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat-history/$userId/$sessionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('chat session response: ${response.body}');
        return ChatSession.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading chat session: $e');
      return null;
    }
  }

  // Delete chat session
  static Future<bool> deleteChatSession(String sessionId) async {
    try {
      final userId = await getUserId();
      if (userId == null) return false;

      final headers = await getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/chat-history/$userId/$sessionId'),
        headers: headers,
      );
      debugPrint('chat delete response: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting chat session: $e');
      return false;
    }
  }
}