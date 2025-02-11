import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    final url = Uri.parse('http://192.168.0.42:8000/api/update-profile');

    try {
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Fluttertoast.showToast(
          msg: data['message'] ?? 'Profile updated successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        await prefs.setString('username', name);
        await prefs.setString('email', email);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } else {
        final errorData = json.decode(response.body);
        Fluttertoast.showToast(
          msg: errorData['message'] ?? 'Failed to update profile',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
