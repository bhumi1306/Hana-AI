import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Utility/commons.dart';

class RegisterUser {

  Future<http.Response> registerUser(String username, String email, String password) async {
    debugPrint(username);
    debugPrint(email);

    final data = jsonEncode({
      "username": username,
      "email": email,
      "password": password
    });
    try {
      final response = await http.post(
          Uri.parse('$baseUrl/register'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: data
      );
      if (response.statusCode == 200) {
        debugPrint("success otp sent");
        return response;
      }
      else if (response.statusCode == 400) {
        debugPrint("already registered");
        return response;
      }
      else {
        debugPrint("body : ${response.body}");
        debugPrint("code: ${response.statusCode}");
        throw Exception('Please try again.');
      }
    } catch (e) {
      debugPrint("$e");
      throw HttpException(e.toString().substring(11));
    }
  }
}
class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}
