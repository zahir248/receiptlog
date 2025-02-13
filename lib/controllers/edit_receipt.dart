import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import '../config/config.dart';
import '../views/dashboard.dart';

class ReceiptController {
  Future<void> updateReceipt({
    required BuildContext context,
    required int receiptId,
    required String storeName,
    required double totalAmount,
    required DateTime date,
  }) async {
    try {
      final url = Uri.parse('${Config.baseUrl}/receipts/$receiptId');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'store_name': storeName,
          'total_amount': totalAmount,
          'date': date.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        _showToast("Receipt updated successfully", Colors.green);
        FocusScope.of(context).unfocus();

        await Future.delayed(const Duration(seconds: 1));

        if (context.mounted) {
          _navigateToDashboard(context);
        }
      } else {
        _showErrorDialog(context, "Failed to update receipt: ${response.body}");
      }
    } catch (e) {
      _showErrorDialog(context, "Error updating receipt: $e");
    }
  }

  void _navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    );
  }

  void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: bgColor,
      textColor: Colors.white,
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
