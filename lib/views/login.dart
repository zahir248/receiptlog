import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'register.dart';
import '../controllers/login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // State variable to toggle password visibility
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF003300),
              Color(0xFF004d00),
              Color(0xFF006600),
              Color(0xFF339933),
            ],
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
                  'Login to SCAN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                // Email field
                TextField(
                  controller: emailController,
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
                // Password field with visibility icon
                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible, // Control password visibility
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock, color: Colors.black),
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      if (email.isNotEmpty && password.isNotEmpty) {
                        LoginController.login(email, password, context);
                      } else {
                        Fluttertoast.showToast(
                          msg: "Please fill in all fields",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      primary: const Color(0xFF006600),
                      onPrimary: Colors.white,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // "Don't have an account?" and "Register here" link closely
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "Register here",
                        style: TextStyle(
                          color: Colors.blue,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Allows full-height modal if needed
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            backgroundColor: Colors.white,
            builder: (context) => _buildSystemDetailsModal(),
          );
        },
        backgroundColor: Colors.green, // Matching theme color
        child: const Icon(Icons.info, color: Colors.white), // Info icon
      ),
    );
  }

  Widget _buildSystemDetailsModal() {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6, // Adjust modal height
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button (X)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                // System Name
                const Center(
                  child: Text(
                    "Grocery Receipt Record Management System",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Overview
                const Text(
                  "Overview",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Welcome to ",
                      ),
                      TextSpan(
                        text: "SCAN",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: " – A system that helps you track and manage your grocery expenses. Store receipts, track purchases, and generate reports effortlessly with secure cloud storage.",
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 15),
                // Key Features
                const Text(
                  "Key Features",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.receipt, color: Colors.green),
                      title: Text.rich(
                        TextSpan(
                          text: "Receipt Management",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Text("• Create, update, and delete receipts.\n"
                          "• Store details like store name, total amount, and date.\n "
                          "• Link receipts to a specific user."),
                    ),
                    ListTile(
                      leading: Icon(Icons.list, color: Colors.green),
                      title: Text.rich(
                        TextSpan(
                          text: "Receipt Item Management",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Text(
                        "• Add, update, and delete items in a receipt.\n"
                            "• Track item details such as name, quantity, and price.\n"
                            "• Automatically update the receipt’s total amount when items change.",
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.picture_as_pdf, color: Colors.green),
                      title: Text.rich(
                        TextSpan(
                          text: "Reporting",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      subtitle: Text("• Generate detailed receipts with itemized lists in PDF format.\n "
                          "• View receipts sorted by date for better organization."),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Benefits
                const Text(
                  "Benefits",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "✔ Easily track and organize receipts and items\n"
                      "✔ Automatic updates to receipt totals when changes are made\n"
                      "✔ Create detailed reports to understand spending habits",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 15),
                // Getting Started
                const Text(
                  "Getting Started",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "1. Register for an account using your email.\n"
                      "2. Add your first receipt to the system.\n"
                      "3. Include items in your receipt for detailed tracking.\n"
                      "4. View, update, or manage your receipts easily.\n"
                      "5. Generate reports to analyze your spending.\n"
                      "6. Access your receipts and records anytime, anywhere.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                // Close Button
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}