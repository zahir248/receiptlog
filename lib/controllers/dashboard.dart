import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/receipt.dart';
import '../views/dashboard.dart';

class DashboardController {

  static const String baseUrl = 'http://192.168.0.42:8000/api/receipts';

  Future<List<Receipt>> fetchReceipts() async {
    try {
      // Get the userId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception("User ID not found in SharedPreferences.");
      }

      // Send API request to fetch receipts
      final response = await http.get(
        Uri.parse('http://192.168.0.42:8000/api/receipts/$userId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Convert JSON to a list of Receipt objects
        return (data['receipts'] as List)
            .map((json) => Receipt.fromJson(json))
            .toList();
      } else {
        throw Exception("Failed to fetch receipts. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching receipts: $e");
    }
  }

  static Future<bool> deleteReceipt(
      BuildContext context,
      int receiptId,
      Function(int) onDeleteSuccess,
      ) async {
    final url = Uri.parse('$baseUrl/$receiptId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Call the callback to update the UI
        onDeleteSuccess(receiptId);

        // Show success message
        Fluttertoast.showToast(
          msg: "Receipt deleted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Optional delay to show toast
        await Future.delayed(const Duration(seconds: 1));

        // Navigate to dashboard
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          );
        }

        return true;
      } else {
        print('Failed to delete receipt: ${response.body}');

        // Show error message
        Fluttertoast.showToast(
          msg: "Failed to delete receipt",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        return false;
      }
    } catch (e) {
      print('Error deleting receipt: $e');

      // Show error message
      Fluttertoast.showToast(
        msg: "Error deleting receipt: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return false;
    }
  }
}
