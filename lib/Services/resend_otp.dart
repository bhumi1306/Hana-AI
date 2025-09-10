import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Utility/commons.dart';

class ResendOtp {

  Future<http.Response> resendOtp(String email) async {
    debugPrint(email);

    final data = jsonEncode({
      "email": email,
    });
    try {
      final response = await http.post(
          Uri.parse('$baseUrl/resend-otp'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: data
      );
      if (response.statusCode == 200) {
        debugPrint("success otp sent again");
        return response;
      }
      else if (response.statusCode == 400) {
        debugPrint("already registered or not found");
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
