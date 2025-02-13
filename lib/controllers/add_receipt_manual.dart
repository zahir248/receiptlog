import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/config.dart';

class ReceiptController {
  Future<int?> _getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> submitReceipt({
    required String storeName,
    required DateTime date,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      int? userId = await _getUserId();
      if (userId == null) {
        onError("User ID is null");
        return;
      }

      final url = Uri.parse('${Config.baseUrl}/receipts');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'store_name': storeName,
          'date': date.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        _showToast("Receipt added successfully", Colors.green);
        onSuccess();
      } else {
        _showToast("Failed to add receipt", Colors.red);
        onError("Error: ${response.body}");
      }
    } catch (e) {
      _showToast("An error occurred", Colors.red);
      onError("Exception: $e");
    }
  }

  void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: bgColor,
      textColor: Colors.white,
    );
  }
}
