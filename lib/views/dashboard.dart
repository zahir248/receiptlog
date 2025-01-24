import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/receipt.dart';
import '../controllers/dashboard.dart';
import '../views/login.dart';
import '../views/edit_receipt.dart';

class DashboardPage extends StatefulWidget {
  final String? username;

  const DashboardPage({super.key, this.username});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardController _controller = DashboardController();
  List<Receipt> receipts = [];
  bool isLoading = true;

  String getInitials(String storeName) {
    if (storeName.isEmpty) return '';

    // Split the store name into words
    List<String> words = storeName.trim().split(' ');

    // If it's a single word, take first two characters
    if (words.length == 1) {
      return words[0].length > 1
          ? words[0].substring(0, 2).toUpperCase()
          : words[0].substring(0, 1).toUpperCase();
    }

    // If multiple words, take first letter of first two words
    return (words[0][0] + (words.length > 1 ? words[1][0] : '')).toUpperCase();
  }

  Future<void> deleteReceipt(int receiptId) async {
    final url = Uri.parse('http://192.168.0.82:8000/api/receipts/$receiptId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Add any necessary authentication headers here
      },
    );

    if (response.statusCode == 200) {
      // Successfully deleted
      setState(() {
        receipts.removeWhere((receipt) => receipt.id == receiptId); // Access `id` field here
      });

      // Show success message with FlutterToast
      Fluttertoast.showToast(
        msg: "Receipt deleted successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Navigate to DashboardPage after showing success message
      await Future.delayed(const Duration(seconds: 1)); // Optional delay to allow the toast to be visible
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()), // Navigate back to the dashboard
      );
    } else {
      // Handle errors
      print('Failed to delete receipt: ${response.body}');
      // You could show an error dialog here if needed
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchReceipts();
  }

  Future<void> _fetchReceipts() async {
    try {
      final fetchedReceipts = await _controller.fetchReceipts();
      setState(() {
        receipts = fetchedReceipts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.username != null && widget.username!.isNotEmpty
              ? '${widget.username}\'s Receipt Record'
              : 'Guest\'s Receipt Record', // Default to "Guest's Receipt Record"
          style: TextStyle(color: Colors.white), // Set the text color to white
        ),
        backgroundColor: Colors.black, // AppBar background color is black
        elevation: 0, // Remove shadow to create a seamless blend
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white), // Set the icon color to white
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the drawer when the menu button is clicked
            },
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black, // Set drawer background to black
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer header
            const DrawerHeader(
              decoration: BoxDecoration(
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
              child: Text(
                '',
              ),
            ),
            // List of items for the sidebar
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white), // Add icon
              title: const Text(
                'Update Profile',
                style: TextStyle(
                  color: Colors.white, // White text
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // Handle profile action
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.white), // Add icon
              title: const Text(
                'View Report',
                style: TextStyle(
                  color: Colors.white, // White text
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // Handle settings action
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white), // Add icon
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white, // White text
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  barrierDismissible: false, // Prevent closing the dialog by tapping outside
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0), // Rounded corners
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30), // Icon for a professional look
                          const SizedBox(width: 8),
                          const Text(
                            'Confirm Logout',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Title styling
                          ),
                        ],
                      ),
                      content: const Text(
                        'Are you sure you want to log out?',
                        style: TextStyle(fontSize: 16, color: Colors.black87), // Content styling
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the buttons horizontally
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Close the dialog
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300], // Light gray for "Cancel"
                                foregroundColor: Colors.black, // Black text for contrast
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 16), // Space between the buttons
                            ElevatedButton(
                              onPressed: () async {
                                // Clear stored session or user data
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.clear(); // Clear all saved preferences

                                // Close the dialog
                                Navigator.of(context).pop();

                                // Redirect to login page
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red, // Red for "Log Out"
                                foregroundColor: Colors.white, // White text for contrast
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: const Text('Log Out'),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),

      // Add this after your drawer definition and before the body in the Scaffold
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          // Show bottom sheet with options
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (BuildContext context) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Add Receipt',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.green.shade700,
                        ),
                      ),
                      title: const Text('Scan Receipt'),
                      subtitle: const Text('Take a photo of your receipt'),
                      onTap: () {
                        // Handle camera action
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit_document,
                          color: Colors.green.shade700,
                        ),
                      ),
                      title: const Text('Manual Entry'),
                      subtitle: const Text('Enter receipt details manually'),
                      onTap: () {
                        // Handle manual entry
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : receipts.isEmpty
            ? const Center(
          child: Text(
            "No receipts found.",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: receipts.length,
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              final formattedDate =
              DateFormat('yyyy-MM-dd').format(receipt.date);

              return InkWell (
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Receipt Options',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.list,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                title: const Text('View Items'),
                                onTap: () {
                                  // Close the modal
                                  Navigator.of(context).pop();
                                },
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                title: const Text('Edit Receipt'),
                                onTap: () {
                                  // Close the modal
                                  Navigator.of(context).pop();
                                  // Assume you have a EditReceiptPage that takes a receipt as a parameter
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditReceiptPage(receipt: receipt),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                title: const Text('Delete Receipt'),
                                onTap: () {
                                // Show confirmation dialog before deleting
                                showDialog(
                                  context: context,
                                  barrierDismissible: false, // Prevent closing the dialog by tapping outside
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white, // Set background color to white
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.0), // Rounded corners
                                      ),
                                      title: Row(
                                        children: [
                                          Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30), // Icon for a professional look
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Confirm Delete',
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Title styling
                                          ),
                                        ],
                                      ),
                                      content: const Text('Are you sure you want to delete this receipt?',
                                        style: TextStyle(fontSize: 16, color: Colors.black87),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close dialog
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300], // Light gray for "Cancel"
                                            foregroundColor: Colors.black, // Black text for contrast
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await deleteReceipt(receipt.id); // Access the 'id' property of the Receipt object
                                            Navigator.of(context).pop(); // Close dialog
                                            Navigator.of(context).pop(); // Close bottom sheet after delete
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red, // Red for "Log Out"
                                            foregroundColor: Colors.white, // White text for contrast
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },

              child: Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.white,
                          Colors.green.shade50,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Circle with store initials
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.green.shade400,
                                  Colors.green.shade600,
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                getInitials(receipt.storeName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Main content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        receipt.storeName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "RM ${receipt.totalAmount.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // Icon(
                                    //   Icons.calendar_today,
                                    //   size: 14,
                                    //   color: Colors.grey[600],
                                    // ),
                                    // const SizedBox(width: 4),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              );
            },
          ),
        ),
      ),
    );
  }
}
