import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

import '../views/dashboard.dart';
import '../models/receipt.dart';

class ViewItemsPage extends StatefulWidget {
  final Receipt receipt;

  const ViewItemsPage({Key? key, required this.receipt}) : super(key: key);

  @override
  _ViewItemsPageState createState() => _ViewItemsPageState();
}

class _ViewItemsPageState extends State<ViewItemsPage> {
  List<dynamic> items = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchReceiptItems();
  }

  Future<void> fetchReceiptItems() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.3:8000/api/receipt-items/${widget.receipt.id}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          items = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load items.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(int receiptId, int itemId, String itemName) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.0.3:8000/api/receipts/$receiptId/items/$itemId'), // Modified URL to include receiptId
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Remove item from local list
        setState(() {
          items.removeWhere((item) => item['id'] == itemId);
        });

        // Show success toast
        Fluttertoast.showToast(
          msg: "Item deleted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        // Error handling
        Fluttertoast.showToast(
          msg: "Failed to delete item",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _updateItem({
    required int receiptId,
    required int itemId,
    required String itemName,
    required int quantity,
    required double price,
  }) async {
    try {
      final requestBody = jsonEncode({
        'item_name': itemName,
        'quantity': quantity,
        'price': price,
      });

      final url = 'http://192.168.0.3:8000/api/receipts/$receiptId/items/$itemId';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        // Show success message using FlutterToast
        Fluttertoast.showToast(
          msg: "Item updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        // Show error message using FlutterToast
        Fluttertoast.showToast(
          msg: "Failed to update item",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      // Show error message for network issue
      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage()),
          ),
        ),
        title: Text(
          'Receipt\'s Item: ${widget.receipt.date.toLocal().toString().split(' ')[0]}',
          style: const TextStyle(color: Colors.white),
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(
          child: Text(
            errorMessage, // Display the error message
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
            : items.isEmpty // Check if no items exist
            ? Center(
          child: Text(
            "No items found",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return InkWell(
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
                            'Item Options',
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
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.edit,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            title: const Text('Edit Item'),
                            onTap: () {
                              Navigator.of(context).pop(); // Close the modal
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  // Pre-fill controllers with existing item data
                                  TextEditingController itemNameController = TextEditingController(text: item['item_name'] ?? '');
                                  TextEditingController itemQuantityController = TextEditingController(text: item['quantity']?.toString() ?? '');
                                  TextEditingController itemPriceController = TextEditingController(
                                      text: _parsePrice(item['price']).toStringAsFixed(2)
                                  );

                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    title: const Text(
                                      'Edit Item',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: itemNameController,
                                          decoration:  InputDecoration(
                                            labelText: 'Item Name',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: itemQuantityController,
                                          keyboardType: TextInputType.number,
                                          decoration:  InputDecoration(
                                            labelText: 'Quantity',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: itemPriceController,
                                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                                          decoration:  InputDecoration(
                                            labelText: 'Price (RM)',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey[300],
                                                foregroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                            const SizedBox(width: 16.0),
                                            ElevatedButton(
                                              onPressed: () async {
                                                // Update item via API
                                                await _updateItem(
                                                  receiptId: widget.receipt.id,
                                                  itemId: item['id'],
                                                  itemName: itemNameController.text,
                                                  quantity: int.parse(itemQuantityController.text),
                                                  price: double.parse(itemPriceController.text),
                                                );

                                                // Close the dialog and bottom sheet
                                                Navigator.of(context).pop(); // Close dialog

                                                // Refresh the page by calling setState
                                                setState(() {
                                                  fetchReceiptItems();
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                              child: const Text('Save'),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                                },
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
                            title: const Text('Delete Item'),
                            onTap: () {
                              // Show confirmation dialog for delete
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Confirm Delete',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    content: const Text(
                                      'Are you sure you want to delete this item?',
                                      style: TextStyle(fontSize: 16, color: Colors.black87),
                                    ),
                                    actions: [
                                      Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close dialog
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey[300],
                                                foregroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                              child: const Text('Cancel'),
                                            ),
                                            const SizedBox(width: 16.0),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await _deleteItem(
                                                  widget.receipt.id, // Pass the receiptId as the first argument
                                                  item['id'],        // Pass the itemId as the second argument
                                                  item['item_name'], // Pass the itemName as the third argument
                                                );
                                                Navigator.of(context).pop(); // Close dialog
                                                Navigator.of(context).pop(); // Close bottom sheet after delete
                                              },

                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      )
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
                        // Circle with item initial
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
                              _getItemNumber(index), // Display the item number
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
                                      item['item_name'] ?? 'Unknown Item',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      overflow: TextOverflow.visible, // Allows wrapping
                                      softWrap: true, // Ensures the text will wrap to the next line if needed
                                    )
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
                                      "RM ${_parsePrice(item['price']).toStringAsFixed(2)}",
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
                              Text(
                                'Quantity: ${item['quantity'] ?? 0}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
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
    );
  }

  String _getItemNumber(int index) {
    return (index + 1).toString(); // Display index + 1 (to start from 1 instead of 0)
  }

  double _parsePrice(dynamic price) {
    // If price is already a number, return it as a double
    if (price is num) {
      return price.toDouble();
    }
    // If price is a string, try parsing it to a double
    if (price is String) {
      return double.tryParse(price) ?? 0.0; // Return 0.0 if parsing fails
    }
    // If it's neither, return 0.0
    return 0.0;
  }
}
