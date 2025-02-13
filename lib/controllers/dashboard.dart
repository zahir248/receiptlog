import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../config/config.dart';
import '../models/receipt.dart';
import '../views/dashboard.dart';

class DashboardController {

  static final String baseUrl = '${Config.baseUrl}/receipts';

  Future<List<Receipt>> fetchReceipts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception("User ID not found in SharedPreferences.");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['receipts'] as List).map((json) => Receipt.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch receipts. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching receipts: $e");
    }
  }

  static Future<bool> deleteReceipt(BuildContext context, int receiptId, Function(int) onDeleteSuccess) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$receiptId'), headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        onDeleteSuccess(receiptId);
        _showToast("Receipt deleted successfully", Colors.green);

        await Future.delayed(const Duration(seconds: 1));

        if (context.mounted) {
          _navigateToDashboard(context);
        }
        return true;
      } else {
        _showToast("Failed to delete receipt", Colors.red);
        return false;
      }
    } catch (e) {
      _showToast("Error deleting receipt: $e", Colors.red);
      return false;
    }
  }

  static void _navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardPage()));
  }

  static void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: bgColor,
      textColor: Colors.white,
    );
  }
}
