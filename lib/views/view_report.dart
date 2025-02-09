import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

import '../views/dashboard.dart';

class ViewReportPage extends StatefulWidget {
  @override
  _ViewReportPageState createState() => _ViewReportPageState();
}

class _ViewReportPageState extends State<ViewReportPage> {
  Map<String, List<dynamic>> groupedReports = {};
  List<dynamic> detailedReports = [];
  bool isLoading = true;
  int userId = 0;
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserIdAndFetchReports();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Future<void> getUserIdAndFetchReports() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUserId = prefs.getInt('userId');

    if (storedUserId == null) {
      Fluttertoast.showToast(
        msg: "Error: User ID not found",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      userId = storedUserId;
    });

    fetchReports(storedUserId);
  }

  Future<void> fetchReports(int userId) async {
    try {
      final url = 'http://192.168.0.4:8000/api/reports?user_id=$userId';
      print("Fetching reports from: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Store detailed reports for PDF generation
        setState(() {
          detailedReports = data;
        });

        // Group reports by store name for display
        Map<String, List<dynamic>> groupedByStore = {};
        for (var report in data) {
          String monthYear = report['date'] != null
              ? DateTime.parse(report['date']).toString().substring(0, 7)
              : 'Unknown';

          if (!groupedByStore.containsKey(monthYear)) {
            groupedByStore[monthYear] = [];
          }
          groupedByStore[monthYear]!.add(report);
        }

        setState(() {
          groupedReports = groupedByStore;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load reports");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(
        msg: "Error: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> generateAndDownloadPDF() async {
    try {
      // Get the list of unique store names from the detailedReports
      List<String> stores = detailedReports
          .map((report) => (report['store_name'] ?? 'Unknown Store').toString())
          .toSet()
          .toList();

      // Show the store selection dialog
      String? selectedStore = await showStoreSelectionDialog(context, stores);

      if (selectedStore == null) {
        // User canceled the dialog
        return;
      }

      // Load TTF font file
      final ByteData fontData = await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
      final ttf = pw.Font.ttf(fontData.buffer.asByteData());

      final pdf = pw.Document();

      // Filter reports by the selected store
      List<dynamic> filteredReports = detailedReports
          .where((report) => report['store_name'] == selectedStore)
          .toList();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          theme: pw.ThemeData(defaultTextStyle: pw.TextStyle(font: ttf)),
          build: (pw.Context context) {
            List<pw.Widget> widgets = [];

            widgets.add(
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Detailed Receipt Report for $selectedStore',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );

            widgets.add(pw.SizedBox(height: 20));

            // Add receipts for the selected store
            for (var receipt in filteredReports) {
              widgets.add(
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black),
                  ),
                  padding: pw.EdgeInsets.all(10),
                  margin: pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Date: ${receipt['date'] ?? 'N/A'}',
                        style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.SizedBox(height: 10),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        children: [
                          pw.TableRow(
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'No.',
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Item',
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Quantity',
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Padding(
                                padding: pw.EdgeInsets.all(5),
                                child: pw.Text(
                                  'Price (RM)',
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          ...((receipt['items'] ?? []) as List).asMap().map((index, item) {
                            return MapEntry(index, pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    '${index + 1}',
                                    style: pw.TextStyle(font: ttf),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    item['item_name'] ?? 'N/A',
                                    style: pw.TextStyle(font: ttf),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    item['quantity'].toString(),
                                    style: pw.TextStyle(font: ttf),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw.EdgeInsets.all(5),
                                  child: pw.Text(
                                    '${item['price'].toString()}',
                                    style: pw.TextStyle(font: ttf),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                              ],
                            ));
                          }).values.toList(),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Total Quantity: ${receipt['items']?.fold(0, (sum, item) => sum + (item['quantity'] ?? 0))}',
                          style: pw.TextStyle(
                            font: ttf,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 5), // Small gap before Total Amount
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'Total Amount: RM ${receipt['total_amount'] ?? '0.00'}',
                          style: pw.TextStyle(
                            font: ttf,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return widgets;
          },
        ),
      );

      // Try to share the PDF directly without saving
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'detailed_receipt_report_$selectedStore.pdf',
      ).then((_) {
        Fluttertoast.showToast(
          msg: "PDF generated successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      });
    } catch (e) {
      print("Error generating PDF: $e");
      Fluttertoast.showToast(
        msg: "Error generating PDF: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "View Report by Month",
          style: const TextStyle(color: Colors.white),
        ),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Start Date Button
                  _buildDateButton(
                    label: startDate == null
                        ? "Select Start Date"
                        : "Start: ${startDate!.toLocal().toString().split(' ')[0]}",
                    icon: Icons.calendar_today,
                    onPressed: () => _selectStartDate(context),
                  ),

                  // End Date Button
                  _buildDateButton(
                    label: endDate == null
                        ? "Select End Date"
                        : "End: ${endDate!.toLocal().toString().split(' ')[0]}",
                    icon: Icons.calendar_today,
                    onPressed: () => _selectEndDate(context),
                  ),

                  // Reset Button
                  _buildResetButton(),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : groupedReports.isEmpty
                  ? Center(
                child: Text(
                  "No reports available",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: groupedReports.keys.length,
                itemBuilder: (context, index) {
                  String monthYear = groupedReports.keys.elementAt(index);
                  List<dynamic> reports = groupedReports[monthYear]!;

                  // Filter reports based on date range and search query
                  List<dynamic> filteredReports = reports.where((report) {
                    DateTime reportDate = DateTime.parse(report['date']);
                    return (startDate == null || reportDate.isAfter(startDate!)) &&
                        (endDate == null || reportDate.isBefore(endDate!));
                  }).toList();

                  if (filteredReports.isEmpty) {
                    return SizedBox.shrink(); // Hide this month if no reports match
                  }

                  // Step 1: Group by store name and sum total amount
                  Map<String, double> storeTotals = {};

                  for (var report in filteredReports) {
                    String storeName = report['store_name'] ?? 'Unknown Store';
                    double totalAmount = double.tryParse(report['total_amount'].toString()) ?? 0.0;

                    if (storeTotals.containsKey(storeName)) {
                      storeTotals[storeName] = storeTotals[storeName]! + totalAmount;
                    } else {
                      storeTotals[storeName] = totalAmount;
                    }
                  }

                  return Card(
                    margin: EdgeInsets.all(8),
                    color: Colors.white.withOpacity(0.9),
                    child: ExpansionTile(
                      title: Text(
                        "$monthYear",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: storeTotals.entries.map((entry) {
                        return ListTile(
                          title: Text(entry.key),
                          subtitle: Text(
                              "Total Spending Amount: RM ${entry.value.toStringAsFixed(2)}"),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: generateAndDownloadPDF,
        backgroundColor: Colors.green,
        child: Icon(Icons.picture_as_pdf, color: Colors.white),
      ),
    );
  }

  Future<String?> showStoreSelectionDialog(BuildContext context, List<String> stores) async {
    String? selectedStore;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white, // Ensure modal background is white
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Makes the dialog size adapt to content
              children: [
                Text(
                  "Select a Store",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Divider(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 300, // Prevent overflow for large lists
                  ),
                  child: ListView.builder(
                    shrinkWrap: true, // Ensures the list only takes necessary space
                    physics: BouncingScrollPhysics(),
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          selectedStore = stores[index];
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          margin: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200], // Light background color
                          ),
                          child: Text(
                            stores[index],
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog without selecting
                  },
                  icon: Icon(Icons.cancel, color: Colors.white),
                  label: Text("Cancel"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return selectedStore;
  }

  Widget _buildResetButton() {
    return Container(
      width: 120,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.red, // Button color
          onPrimary: Colors.white, // Text color
          elevation: 5, // Elevation for shadow effect
        ),
        onPressed: () {
          setState(() {
            startDate = null;
            endDate = null;
            searchController.clear();
          });
        },
        child: Text(
          "Reset",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 120,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          primary: Colors.blue, // Button color
          onPrimary: Colors.white, // Text color
          elevation: 5, // Elevation for shadow effect
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}