import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/receipt.dart';

class DashboardController {

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

}
