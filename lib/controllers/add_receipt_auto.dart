import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

import '../models/receipt.dart';
import '../models/receipt_item.dart';

class AddReceiptController {
  static const String baseUrl = 'http://192.168.0.42:8000/api/receipts/auto';

  static Future<int?> saveReceipt(Receipt receipt, List<ReceiptItem> items) async {
    final Map<String, dynamic> requestData = {
      'user_id': receipt.userId,
      'store_name': receipt.storeName,
      'total_amount': receipt.totalAmount,
      'date': receipt.date.toIso8601String(),
      'items': items.map((item) => {
        'item_name': item.itemName,
        'quantity': item.quantity,
        'price': item.price,
      }).toList(),
    };

    print('Request URL: $baseUrl');
    print('Request Headers: {Content-Type: application/json}');
    print('Request Body: ${jsonEncode(requestData)}');

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestData),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);

        Fluttertoast.showToast(
          msg: "Receipt saved successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        return responseData['receipt_id'];
      } else {
        Fluttertoast.showToast(
          msg: "Failed to save receipt: ${response.statusCode}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        return null;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error saving receipt: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return null;
    }
  }
}