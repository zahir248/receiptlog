import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ViewItemController {

  static const String baseUrl = 'http://192.168.0.42:8000/api/receipts';

  static Future<bool> createItem({
    required int receiptId,
    required String itemName,
    required int quantity,
    required double price,
    required Function refreshItems,
  }) async {
    try {
      final requestBody = jsonEncode({
        'item_name': itemName,
        'quantity': quantity,
        'price': price,
      });

      final url = '$baseUrl/$receiptId/items';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 201) {
        // Refresh the items list using the callback
        await refreshItems();

        // Show success message
        Fluttertoast.showToast(
          msg: "Item added successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        return true;
      } else {
        // Show error message
        Fluttertoast.showToast(
          msg: "Failed to add item",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        return false;
      }
    } catch (e) {
      // Show error message for network issue
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

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
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Call the callback to update the UI
        onDeleteSuccess(itemId);

        // Show success toast
        Fluttertoast.showToast(
          msg: "Item deleted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        return true;
      } else {
        // Error handling
        Fluttertoast.showToast(
          msg: "Failed to delete item",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );

        return false;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );

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
      final requestBody = jsonEncode({
        'item_name': itemName,
        'quantity': quantity,
        'price': price,
      });

      final url = '$baseUrl/$receiptId/items/$itemId';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        // Call the callback to refresh items
        await refreshItems();

        // Show success message
        Fluttertoast.showToast(
          msg: "Item updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        return true;
      } else {
        // Show error message
        Fluttertoast.showToast(
          msg: "Failed to update item",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        return false;
      }
    } catch (e) {
      // Show error message for network issue
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return false;
    }
  }

  static Future<List<dynamic>> fetchReceiptItems(int receiptId) async {
    try {

      final url = Uri.parse('$baseUrl/receipt-items/$receiptId');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Server Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching items: $e');
    }
  }

}