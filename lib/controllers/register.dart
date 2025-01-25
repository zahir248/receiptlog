import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterController {
  final String apiUrl = "http://192.168.0.3:8000/api/register";

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Making a POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      // Handling success response
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Check the status field from your API response
        if (responseData['status'] == 200) {
          return {
            "success": true,
            "data": responseData,
            "message": responseData['message'] ?? "Registration successful!"
          };
        } else {
          return {
            "success": false,
            "message": responseData['message'] ?? "Registration failed"
          };
        }
      }

      // Handling error responses
      else {
        final responseData = json.decode(response.body);
        return {
          "success": false,
          "message": responseData['message'] ??
              "An error occurred. Please try again later."
        };
      }
    } catch (e) {
      // Handling exceptions like connection errors
      return {
        "success": false,
        "message": "A network error occurred: $e",
      };
    }
  }
}
