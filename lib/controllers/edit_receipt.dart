import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

import '../models/receipt.dart';
import '../views/dashboard.dart';

class ReceiptController {
  Future<void> updateReceipt({
    required BuildContext context,
    required int receiptId,
    required String storeName,
    required double totalAmount,
    required DateTime date,
  }) async {
    final url = Uri.parse('http://192.168.0.42:8000/api/receipts/$receiptId');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'store_name': storeName,
        'total_amount': totalAmount,
        'date': date.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      // Successfully updated the receipt
      final updatedReceipt = Receipt.fromJson(jsonDecode(response.body)['receipt']);

      // Close the keyboard
      FocusScope.of(context).unfocus();

      // Show success message
      Fluttertoast.showToast(
        msg: "Receipt updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      await Future.delayed(const Duration(seconds: 1));

      // Navigate back to the dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } else {
      // Handle errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to update receipt: ${response.body}'),
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
}
