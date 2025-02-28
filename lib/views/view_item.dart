import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../views/dashboard.dart';
import '../models/receipt.dart';
import '../controllers/view_item.dart';

class ViewItemsPage extends StatefulWidget {
  final Receipt receipt;

  const ViewItemsPage({Key? key, required this.receipt}) : super(key: key);

  @override
  _ViewItemsPageState createState() => _ViewItemsPageState();
}

class _ViewItemsPageState extends State<ViewItemsPage> {
  List<dynamic> items = [];
  List<dynamic> filteredItems = []; // New list for filtered items
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadReceiptItems();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose(); // Clean up the controller
    super.dispose();
  }

  void _filterItems() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      if (searchTerm.isEmpty) {
        filteredItems = List.from(items);
      } else {
        filteredItems = items
            .where((item) =>
            item['item_name'].toString().toLowerCase().contains(searchTerm))
            .toList();
      }
    });
  }

  Future<void> loadReceiptItems() async {
    try {
      final itemsData = await ViewItemController.fetchReceiptItems(widget.receipt.id);
      setState(() {
        items = itemsData;
        filteredItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          // Show dialog to add new item
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              // Controllers for input fields
              TextEditingController itemNameController = TextEditingController();
              TextEditingController itemQuantityController = TextEditingController();
              TextEditingController itemPriceController = TextEditingController();

              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                title: const Text(
                  'Add New Item',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: itemNameController,
                      decoration: InputDecoration(
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
                      decoration: InputDecoration(
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
                      decoration: InputDecoration(
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
                            String itemName = itemNameController.text.trim();
                            String itemQuantity = itemQuantityController.text.trim();
                            String itemPrice = itemPriceController.text.trim();

                            // 1️⃣ Check if any field is empty
                            if (itemName.isEmpty || itemQuantity.isEmpty || itemPrice.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Please fill in all fields",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              return;
                            }

                            // 2️⃣ Validate item_name (max length 255)
                            if (itemName.length > 255) {
                              Fluttertoast.showToast(
                                msg: "Item name must not exceed 255 characters",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              return;
                            }

                            // 3️⃣ Validate quantity (must be an integer, min: 1)
                            int? quantity = int.tryParse(itemQuantity);
                            if (quantity == null || quantity < 1) {
                              Fluttertoast.showToast(
                                msg: "Quantity must be a valid integer greater than 0",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              return;
                            }

                            // 4️⃣ Validate price (must be numeric, min: 0)
                            double? price = double.tryParse(itemPrice);
                            if (price == null || price < 0) {
                              Fluttertoast.showToast(
                                msg: "Price must be a valid number and at least RM 0",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                              );
                              return;
                            }

                            // ✅ If validation passes, send data to API
                            await ViewItemController.createItem(
                              receiptId: widget.receipt.id,
                              itemName: itemName,
                              quantity: quantity,
                              price: price,
                              refreshItems: loadReceiptItems,
                            );

                            // Close the dialog
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text('Add'),
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
        child: Column(
            children: [
        // Add search bar
        Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by item name...',
              prefixIcon: const Icon(Icons.search, color: Colors.green),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
      Expanded(
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
        itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];

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
                                                String itemName = itemNameController.text.trim();
                                                String itemQuantity = itemQuantityController.text.trim();
                                                String itemPrice = itemPriceController.text.trim();

                                                // 1️⃣ Check if any field is empty
                                                if (itemName.isEmpty || itemQuantity.isEmpty || itemPrice.isEmpty) {
                                                  Fluttertoast.showToast(
                                                    msg: "Please fill in all fields",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.BOTTOM,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                  );
                                                  return;
                                                }

                                                // 2️⃣ Validate item_name (max length 255)
                                                if (itemName.length > 255) {
                                                  Fluttertoast.showToast(
                                                    msg: "Item name must not exceed 255 characters",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.BOTTOM,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                  );
                                                  return;
                                                }

                                                // 3️⃣ Validate quantity (must be an integer, min: 1)
                                                int? quantity = int.tryParse(itemQuantity);
                                                if (quantity == null || quantity < 1) {
                                                  Fluttertoast.showToast(
                                                    msg: "Quantity must be a valid integer greater than 0",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.BOTTOM,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                  );
                                                  return;
                                                }

                                                // 4️⃣ Validate price (must be numeric, min: 0)
                                                double? price = double.tryParse(itemPrice);
                                                if (price == null || price < 0) {
                                                  Fluttertoast.showToast(
                                                    msg: "Price must be a valid number and at least RM0",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.BOTTOM,
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                  );
                                                  return;
                                                }

                                                // ✅ If validation passes, send data to API
                                                final success = await ViewItemController.updateItem(
                                                  receiptId: widget.receipt.id,
                                                  itemId: item['id'],
                                                  itemName: itemName,
                                                  quantity: quantity,
                                                  price: price,
                                                  refreshItems: loadReceiptItems,
                                                );

                                                if (success) {
                                                  Navigator.of(context).pop(); // Close dialog
                                                }
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
                                                final success = await ViewItemController.deleteItem(
                                                  receiptId: widget.receipt.id,
                                                  itemId: item['id'],
                                                  itemName: item['item_name'],
                                                  onDeleteSuccess: (deletedItemId) {
                                                    setState(() {
                                                      items.removeWhere((item) => item['id'] == deletedItemId);
                                                    });
                                                  },
                                                );

                                                if (success) {
                                                  Navigator.of(context).pop(); // Close dialog
                                                  Navigator.of(context).pop(); // Close bottom sheet
                                                }
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
      ]
    )
      )
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
