import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../views/dashboard.dart';

class AddReceiptAutoPage extends StatefulWidget {
  @override
  _AddReceiptPageState createState() => _AddReceiptPageState();
}

class _AddReceiptPageState extends State<AddReceiptAutoPage> {
  File? _receiptImage;
  final ImagePicker _picker = ImagePicker();

  // Function to pick image from Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  // Show modal for image selection
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text("Scan via Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.green),
              title: Text("Upload from Album"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Receipt',
          style: TextStyle(color: Colors.white), // AppBar text color
        ),
        backgroundColor: Colors.black, // AppBar background color
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Back button color
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          },
        ),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _receiptImage != null
                  ? Image.file(_receiptImage!, height: 200)
                  : Text(
                "No receipt selected",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showImagePickerOptions,
                icon: Icon(Icons.receipt),
                label: Text("Add Receipt"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
