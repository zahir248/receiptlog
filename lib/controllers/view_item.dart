import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

import '../config/config.dart';

class ViewItemController {

  static final String baseUrl = '${Config.baseUrl}/receipts';

  static Future<bool> createItem({
    required int receiptId,
    required String itemName,
    required int quantity,
    required double price,
    required Function refreshItems,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$receiptId/items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'item_name': itemName, 'quantity': quantity, 'price': price}),
      );

      if (response.statusCode == 201) {
        await refreshItems();
        _showToast("Item added successfully", Colors.green);
        return true;
      } else {
        _showToast("Failed to add item", Colors.red);
        return false;
      }
    } catch (e) {
      _showToast("Error: ${e.toString()}", Colors.red);
      return false;
    }
  }

  static Future<bool> deleteItem({
    required int receiptId,
    required int itemId,
    required String itemName,
    required Function(int) onDeleteSuccess,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$receiptId/items/$itemId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        onDeleteSuccess(itemId);
        _showToast("Item deleted successfully", Colors.green);
        return true;
      } else {
        _showToast("Failed to delete item", Colors.red);
        return false;
      }
    } catch (e) {
      _showToast("Error: ${e.toString()}", Colors.red);
      return false;
    }
  }

  static Future<bool> updateItem({
    required int receiptId,
    required int itemId,
    required String itemName,
    required int quantity,
    required double price,
    required Function refreshItems,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$receiptId/items/$itemId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'item_name': itemName, 'quantity': quantity, 'price': price}),
      );

      if (response.statusCode == 200) {
        await refreshItems();
        _showToast("Item updated successfully", Colors.green);
        return true;
      } else {
        _showToast("Failed to update item", Colors.red);
        return false;
      }
    } catch (e) {
      _showToast("Error: ${e.toString()}", Colors.red);
      return false;
    }
  }

  static Future<List<dynamic>> fetchReceiptItems(int receiptId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/receipt-items/$receiptId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching items: $e');
    }
  }

  static void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
