import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptController {
  Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> submitReceipt({
    required String storeName,
    required DateTime date,
    required Function onSuccess,
    required Function onError,
  }) async {
    int? userId = await getUserId();
    if (userId == null) {
      onError("User ID is null");
      return;
    }

    final url = Uri.parse('http://192.168.0.42:8000/api/receipts'); // Update with your API URL

    final requestBody = {
      'userId': userId,
      'store_name': storeName,
      'date': date.toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 201) {
      Fluttertoast.showToast(
        msg: "Receipt Added Successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      onSuccess();
    } else {
      Fluttertoast.showToast(
        msg: "Failed to add receipt",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      onError("Failed to add receipt");
    }
  }
}
