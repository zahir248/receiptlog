import 'package:flutter/material.dart';

import '../views/dashboard.dart';
import '../models/receipt.dart';
import '../controllers/edit_receipt.dart';

class EditReceiptPage extends StatefulWidget {
  final Receipt receipt;

  const EditReceiptPage({super.key, required this.receipt});

  @override
  _EditReceiptPageState createState() => _EditReceiptPageState();
}

class _EditReceiptPageState extends State<EditReceiptPage> {
  late TextEditingController _storeNameController;
  late TextEditingController _totalAmountController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _storeNameController = TextEditingController(text: widget.receipt.storeName);
    _totalAmountController = TextEditingController(text: widget.receipt.totalAmount.toString());
    _selectedDate = widget.receipt.date;
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime adjustedInitialDate = _selectedDate.isAfter(now) ? now : _selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: adjustedInitialDate,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveReceipt() {
    ReceiptController().updateReceipt(
      context: context,
      receiptId: widget.receipt.id,
      storeName: _storeNameController.text,
      totalAmount: double.parse(_totalAmountController.text),
      date: _selectedDate,
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          },
        ),
        title: Text(
          'Edit Receipt: ${widget.receipt.date.toLocal().toString().split(' ')[0]}',
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      // Add the header text here
                      Text(
                        'Receipt',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: _storeNameController,
                        decoration: InputDecoration(
                          labelText: 'Store Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // TextField(
                      //   controller: _totalAmountController,
                      //   keyboardType: TextInputType.number,
                      //   enabled: false,  // Makes the TextField non-editable
                      //   decoration: InputDecoration(
                      //     labelText: 'Total Amount',
                      //     prefixText: 'RM ',
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,  // Align everything to the start
                        children: [
                          Text(
                            'Date: ${_selectedDate.toLocal()}'.split(' ')[0],
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),  // Add some space between the text and the icon
                          IconButton(
                            onPressed: () async {
                              await _selectDate(context); // Opens the date picker
                            },
                            icon: const Icon(
                              Icons.calendar_today, // Calendar icon
                              color: Colors.black54, // Icon color
                              size: 28, // Icon size
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveReceipt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
