import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/dashboard.dart';

class LoginController {
  static const String apiUrl = "http://192.168.0.4:8000/api/login";

  static Future<void> login(String email, String password, BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 200) {
          String username = data['user']['name'];
          String email = data['user']['email'];

          int userId = data['user']['id'];

          SharedPreferences prefs = await SharedPreferences.getInstance();

          // Store user data in SharedPreferences
          await prefs.setInt('userId', userId);
          await prefs.setString('username', username);
          await prefs.setString('email', email);

          // print("Debug: UserID stored in SharedPreferences: $userId");

          Fluttertoast.showToast(
            msg: "Welcome, $username! Login successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          // Add a delay of 1 second before navigating to the dashboard
          await Future.delayed(const Duration(seconds: 1));

          // Pass the username when navigating to DashboardPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(), // Pass username
            ),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Unexpected error: ${data['message'] ?? 'Something went wrong.'}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else if (response.statusCode == 401) {
        final data = json.decode(response.body);
        Fluttertoast.showToast(
          msg: data['message'] ?? "Invalid email or password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Unexpected error occurred. Status: ${response.statusCode}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Network error. Check your connection.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
