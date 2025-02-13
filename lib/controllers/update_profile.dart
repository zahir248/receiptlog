import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../views/dashboard.dart';

class UpdateProfileController {
  static Future<void> loadProfileData(
      TextEditingController nameController, TextEditingController emailController) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('username') ?? '';
    emailController.text = prefs.getString('email') ?? '';
  }

  static Future<void> updateProfile(
      BuildContext context, String name, String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        _showToast("User not found. Please log in again.", Colors.red);
        return;
      }

      final url = Uri.parse('${Config.baseUrl}/update-profile');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': userId,
          'name': name,
          'email': email,
          'password': password.isNotEmpty ? password : null,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        await prefs.setString('username', name);
        await prefs.setString('email', email);

        _showToast(data['message'] ?? "Profile updated successfully", Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } else {
        _showToast(data['message'] ?? "Failed to update profile", Colors.red);
      }
    } catch (e) {
      _showToast("Error: $e", Colors.red);
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
