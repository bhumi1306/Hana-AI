import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hana_ai/Utility/commons.dart';
import 'package:http/http.dart' as http;

class VerifyOTP {

  Future<http.Response> verifyOTP(
      int tempId, String otp) async {
    debugPrint("Verifying OTP for tempId: $tempId");


    final data = jsonEncode({
      "temp_user_id": tempId,
      "otp" : otp,
    });
    try {
      final response = await http.post(
          Uri.parse('$baseUrl/verify-email'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: data
      );

      if (response.statusCode == 200) {
        debugPrint("OTP verified Successfully");

        return response;
      }else if (response.statusCode == 400) {
        debugPrint("TempID  or OTP field cannot be empty");
        return response;
      }
      else if (response.statusCode == 409) {
        debugPrint("Invalid OTP");
        return response;
      }
      else {
        debugPrint("body : ${response.body}");
        debugPrint("code: ${response.statusCode}");
        throw Exception('Failed to verify OTP.');
      }
    } catch (e) {
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
