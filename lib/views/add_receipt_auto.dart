import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:math' show min;

import '../views/dashboard.dart';
import '../models/receipt.dart';
import '../models/receipt_item.dart';
import '../controllers/add_receipt_auto.dart';

class AddReceiptAutoPage extends StatefulWidget {
  const AddReceiptAutoPage({Key? key}) : super(key: key);

  @override
  _AddReceiptPageState createState() => _AddReceiptPageState();
}

class _AddReceiptPageState extends State<AddReceiptAutoPage> {
  File? _receiptImage;
  final ImagePicker _picker = ImagePicker();
  String _extractedText = '';
  bool _isProcessing = false;
  Receipt? _parsedReceipt;
  List<ReceiptItem> _parsedItems = [];
  int? _userId; // Store userId here

  // Controllers for editable receipt fields
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserId(); // Fetch userId when the widget is initialized
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _dateController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  // Update controllers when receipt is parsed
  void _updateControllers() {
    if (_parsedReceipt != null) {
      _storeNameController.text = _parsedReceipt!.storeName;
      _dateController.text = _parsedReceipt!.date.toString().split(' ')[0];
      _totalAmountController.text = _parsedReceipt!.totalAmount.toStringAsFixed(2);
    }
  }

  // Fetch userId from SharedPreferences
  Future<void> _fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId'); // Assuming 'userId' is the key used to store the user ID
    });
  }

  // Show dialog to edit an item
  Future<void> _showEditItemDialog(ReceiptItem item, int index) async {
    TextEditingController nameController = TextEditingController(text: item.itemName);
    TextEditingController quantityController = TextEditingController(text: item.quantity.toString());
    TextEditingController priceController = TextEditingController(text: item.price.toStringAsFixed(2));

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog by tapping outside
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Item',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price (RM)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Cancel'),
              ),
              const SizedBox(width: 16), // Add spacing between buttons
              TextButton(
                onPressed: () {
                  setState(() {
                    _parsedItems[index] = ReceiptItem(
                      id: item.id,
                      receiptId: item.receiptId,
                      itemName: nameController.text,
                      quantity: int.tryParse(quantityController.text) ?? 1,
                      price: double.tryParse(priceController.text) ?? 0.0,
                    );
                    _updateTotalAmount();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Show dialog to add a new item
  Future<void> _showAddItemDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController(text: '1');
    TextEditingController priceController = TextEditingController(text: '0.00');

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog by tapping outside
      builder: (context) => AlertDialog(
        title: const Text(
          'Add New Item',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price (RM)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center, // Center the buttons
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Cancel'),
              ),
              const SizedBox(width: 16), // Add spacing between buttons
              TextButton(
                onPressed: () {
                  setState(() {
                    _parsedItems.add(ReceiptItem(
                      id: _parsedItems.length + 1,
                      receiptId: -1,
                      itemName: nameController.text,
                      quantity: int.tryParse(quantityController.text) ?? 1,
                      price: double.tryParse(priceController.text) ?? 0.0,
                    ));
                    _updateTotalAmount();
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text('Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Update total amount based on items
  void _updateTotalAmount() {
    double total = _parsedItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
    _totalAmountController.text = total.toStringAsFixed(2);
    if (_parsedReceipt != null) {
      _parsedReceipt = Receipt(
        id: _parsedReceipt!.id,
        userId: _parsedReceipt!.userId,
        storeName: _storeNameController.text,
        totalAmount: total,
        date: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      );
    }
  }

  Future<(Receipt?, List<ReceiptItem>)> parseReceiptData(String text) async {
    if (_userId == null) {
      return (null, <ReceiptItem>[]);
    }

    String storeName = '';
    DateTime? date;
    List<ReceiptItem> items = [];
    double totalAmount = 0.0;
    int itemId = 1;

    // Split text into lines and remove empty lines
    List<String> lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    print("Processing lines: $lines");

    // Clean and standardize text
    lines = lines.map((line) =>
        line.replaceAll('€', '6')  // Common OCR mistake
            .replaceAll('O', '0')
            .replaceAll('I', '1')
            .replaceAll('l', '1')
            .replaceAll('S.', '5')
            .trim()
    ).toList();

    // 1. Extract store name
    for (String line in lines) {
      if (line.toUpperCase().contains('SPEED MART') ||
          line.toUpperCase().contains('SUPERMART') ||
          line.toUpperCase().contains('SDN BHD') ||
          line.toUpperCase().contains('S/B')) {
        storeName = line.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
        break;
      }
    }

    // 2. Extract date
    RegExp datePattern = RegExp(
        r'(\d{2}[-/.]\d{2}[-/.]\d{2,4})|(\d{2}[-/.]\d{1,2}[-/.]\d{2,4})',
        caseSensitive: false
    );

    for (String line in lines) {
      var match = datePattern.firstMatch(line);
      if (match != null) {
        try {
          String dateStr = (match.group(1) ?? match.group(2))!
              .replaceAll('/', '-')
              .replaceAll('.', '-');
          List<String> parts = dateStr.split('-');
          if (parts[2].length == 2) {
            date = DateTime.parse('20${parts[2]}-${parts[1]}-${parts[0]}');
          } else {
            date = DateTime.parse('${parts[2]}-${parts[1]}-${parts[0]}');
          }
          break;
        } catch (e) {
          print("Error parsing date: $e");
        }
      }
    }

    // 3. Extract items and prices
    List<String> itemBuffer = [];
    List<String> priceBuffer = [];
    RegExp pricePattern = RegExp(r'(?:RM)?(\d+\.\d{2})', caseSensitive: false);
    RegExp itemCodePattern = RegExp(r'^\d{4}\s');
    bool isCollectingItems = false;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim().toUpperCase();

      // Skip known non-item lines
      if (line.contains('INVOICE') ||
          line.contains('CASHIER') ||
          line.contains('TAX') ||
          line.contains('THANK YOU') ||
          line.contains('BALANCE') ||
          line.contains('CREDIT CARD') ||
          line.contains('DEBIT CARD') ||
          RegExp(r'^\d{13}$').hasMatch(line)) { // Barcode
        continue;
      }

      // Start collecting items when we see an item code or RM
      if (!isCollectingItems && (itemCodePattern.hasMatch(line) || line.contains('RM'))) {
        isCollectingItems = true;
      }

      // Stop collecting when we hit the total section
      if (line.contains('TOTAL SALES') || line.contains('TOTAL TO PAY')) {
        isCollectingItems = false;
        continue;
      }

      if (isCollectingItems) {
        // If line contains a price
        if (pricePattern.hasMatch(line)) {
          var prices = pricePattern.allMatches(line)
              .map((m) => double.tryParse(m.group(1) ?? '0') ?? 0.0)
              .where((price) => price > 0)
              .toList();

          if (prices.isNotEmpty) {
            priceBuffer.addAll(prices.map((p) => p.toString()));
          }

          // Extract item name if it's on the same line
          String possibleItem = line.replaceAll(pricePattern, '').trim();
          if (possibleItem.isNotEmpty && !RegExp(r'^[0-9.\s]+$').hasMatch(possibleItem)) {
            itemBuffer.add(possibleItem);
          }
        }
        // If line doesn't contain a price but might be an item name
        else if (!RegExp(r'^[0-9.\s]+$').hasMatch(line)) {
          itemBuffer.add(line);
        }
      }
    }

    // Match items with prices
    print("Item buffer: $itemBuffer");
    print("Price buffer: $priceBuffer");

    int minLength = min(itemBuffer.length, priceBuffer.length);
    for (int i = 0; i < minLength; i++) {
      String itemName = itemBuffer[i].trim();
      double price = double.tryParse(priceBuffer[i]) ?? 0.0;

      if (itemName.isNotEmpty && price > 0) {
        // Clean up item name
        itemName = itemName.replaceAll(RegExp(r'\d{4}\s+'), '') // Remove item codes
            .replaceAll(RegExp(r'\s+'), ' ')       // Normalize spaces
            .trim();

        items.add(ReceiptItem(
          id: itemId++,
          receiptId: -1,
          itemName: itemName,
          quantity: 1,
          price: price,
        ));
        totalAmount += price;
      }
    }

    // Debug print
    print("Found items: ${items.map((item) => '${item.itemName}: ${item.price}').toList()}");
    print("Calculated total: $totalAmount");

    // Create receipt object if valid
    if (storeName.isNotEmpty && items.isNotEmpty) {
      Receipt receipt = Receipt(
        id: -1,
        userId: _userId!,
        storeName: storeName,
        totalAmount: totalAmount,
        date: date ?? DateTime.now(),
      );
      return (receipt, items);
    }

    return (null, <ReceiptItem>[]);
  }

  // Function to pick image from Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
        _isProcessing = true;
        _extractedText = '';
      });

      // Process the image with ML Kit
      await _extractTextFromImage();
    }
  }

  Future<void> _extractTextFromImage() async {
    if (_receiptImage == null) return;

    try {
      final inputImage = InputImage.fromFile(_receiptImage!);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String text = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          text += '${line.text}\n';
        }
      }

      // Parse the extracted text into structured data
      final (receipt, items) = await parseReceiptData(text);

      setState(() {
        _extractedText = text;
        _parsedReceipt = receipt;
        _parsedItems = items;
        _isProcessing = false;
      });

      // Add this line to update the controllers with the parsed data
      _updateControllers();

      await textRecognizer.close();
    } catch (e) {
      setState(() {
        _extractedText = 'Error extracting text: $e';
        _isProcessing = false;
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

  Widget _buildParsedReceiptView() {
    if (_parsedReceipt == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Editable Store Name
          TextField(
            controller: _storeNameController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Store Name',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
            ),
          ),
          // Editable Date
          TextField(
            controller: _dateController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Date (YYYY-MM-DD)',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
            ),
          ),
          // Editable Total Amount
          TextField(
            controller: _totalAmountController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Total Amount (RM)',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white38),
              ),
            ),
            readOnly: true, // Total is calculated from items
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.white),
                onPressed: _showAddItemDialog,
                tooltip: 'Add New Item',
              ),
            ],
          ),
          ..._parsedItems.asMap().entries.map((entry) {
            int index = entry.key;
            ReceiptItem item = entry.value;
            return Padding(
              padding: EdgeInsets.only(left: 16, top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.itemName} - RM ${item.price.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: () => _showEditItemDialog(item, index),
                    tooltip: 'Edit Item',
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.white, size: 20),
                    onPressed: () {
                      setState(() {
                        _parsedItems.removeAt(index);
                        _updateTotalAmount();
                      });
                    },
                    tooltip: 'Delete Item',
                  ),
                ],
              ),
            );
          }).toList(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (_parsedReceipt != null && _userId != null) {
                try {
                  // Show loading indicator
                  setState(() {
                    _isProcessing = true;
                  });

                  // Update receipt with current values
                  final updatedReceipt = Receipt(
                    id: _parsedReceipt!.id,
                    userId: _userId!,
                    storeName: _storeNameController.text,
                    totalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
                    date: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
                  );

                  // Save to backend using the controller
                  final receiptId = await AddReceiptController.saveReceipt(updatedReceipt, _parsedItems);

                  // Navigate back to dashboard
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardPage()),
                  );
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving receipt: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  // Hide loading indicator
                  setState(() {
                    _isProcessing = false;
                  });
                }
              }
            },
            child: Text('Save Receipt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Receipt',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_receiptImage != null) ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_receiptImage!, height: 200),
                  ),
                ),
                SizedBox(height: 20),
              ] else
                Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "No receipt selected",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showImagePickerOptions,
                icon: Icon(Icons.receipt, color: Colors.blue),
                label: Text("Attach Receipt"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
              if (_isProcessing) ...[
                SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
              if (!_isProcessing && _extractedText.isNotEmpty && _receiptImage != null) ...[
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        if (_parsedReceipt != null) _buildParsedReceiptView(),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}