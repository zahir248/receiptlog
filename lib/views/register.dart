import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF003300), // Deep dark green
              Color(0xFF004d00), // Slightly lighter dark green
              Color(0xFF006600), // Richer green tone
              Color(0xFF339933), // Vibrant green at the top
            ],
            stops: [0.0, 0.3, 0.6, 1.0], // Gradient stops to match your pattern
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                // Name field with icon
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.black),
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Email field with icon
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.black),
                    labelText: 'Email Address',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Password field with icon
                TextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.black),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Register button with same width as text fields
                SizedBox(
                  width: double.infinity, // Make the button take up the full width
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle register action
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      primary: const Color(0xFF006600), // Deep green
                      onPrimary: Colors.white,
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // "Already have an account? Login here" link
                Row(
                  mainAxisSize: MainAxisSize.min, // Minimize the row size to fit both texts closely
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to the LoginPage
                        Navigator.pop(context); // Going back to the LoginPage
                      },
                      child: const Text(
                        "Login here",
                        style: TextStyle(
                          color: Colors.blue, // Blue color
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
