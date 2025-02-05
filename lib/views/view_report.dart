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

  @override
  void initState() {
    super.initState();
    getUserIdAndFetchReports();
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
      final url = 'http://192.168.0.42:8000/api/reports?user_id=$userId';
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
      // Load TTF font file
      final ByteData fontData = await rootBundle.load(
          'assets/fonts/OpenSans-Regular.ttf');
      final ttf = pw.Font.ttf(fontData.buffer.asByteData());

      final pdf = pw.Document();

      // Group reports by store name for PDF
      Map<String, List<dynamic>> storeReports = {};
      for (var report in detailedReports) {
        String storeName = report['store_name'] ?? 'Unknown Store';
        if (!storeReports.containsKey(storeName)) {
          storeReports[storeName] = [];
        }
        storeReports[storeName]!.add(report);
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
          theme: pw.ThemeData(
              defaultTextStyle: pw.TextStyle(font: ttf)
          ),
          build: (pw.Context context) {
            List<pw.Widget> widgets = [];

            widgets.add(
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Full Detailed Receipt Report',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            );

            widgets.add(pw.SizedBox(height: 20));

            // Add store sections
            for (var storeEntry in storeReports.entries) {
              widgets.add(
                pw.Align(
                  alignment: pw.Alignment.centerLeft,  // Align to the left
                  child: pw.Text(
                    storeEntry.key,  // Store name
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,  // Bold text
                      decoration: pw.TextDecoration.underline,  // Underline text
                    ),
                  ),
                ),
              );

              widgets.add(pw.SizedBox(height: 10));

              // Add receipts for this store
              for (var receipt in storeEntry.value) {
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
                            style: pw.TextStyle(
                                font: ttf, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 5),
                          // pw.Text(
                          //   'Receipt ID: ${receipt['receipt_id'] ?? 'N/A'}',
                          //   style: pw.TextStyle(font: ttf),
                          // ),
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
                                      textAlign: pw.TextAlign.center,  // Align text to center
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
                                      textAlign: pw.TextAlign.center,  // Align text to center
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
                                      textAlign: pw.TextAlign.center,  // Align text to center
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
                                      textAlign: pw.TextAlign.center,  // Align text to center
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
                                        '${index + 1}', // Display the serial number
                                        style: pw.TextStyle(font: ttf),
                                        textAlign: pw.TextAlign.center,  // Align text to center
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(5),
                                      child: pw.Text(
                                        item['item_name'] ?? 'N/A',
                                        style: pw.TextStyle(font: ttf),
                                        textAlign: pw.TextAlign.center,  // Align text to center
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(5),
                                      child: pw.Text(
                                        item['quantity'].toString(),
                                        style: pw.TextStyle(font: ttf),
                                        textAlign: pw.TextAlign.center,  // Align text to center
                                      ),
                                    ),
                                    pw.Padding(
                                      padding: pw.EdgeInsets.all(5),
                                      child: pw.Text(
                                        '${item['price'].toString()}',
                                        style: pw.TextStyle(font: ttf),
                                        textAlign: pw.TextAlign.center,  // Align text to center
                                      ),
                                    ),
                                  ],
                                ));
                              }).values.toList(),
                            ],
                          ),
                          pw.SizedBox(height: 10),
                          pw.Align(
                            alignment: pw.Alignment.centerRight,  // Align to the right
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
                    )
                );
              }
              widgets.add(pw.SizedBox(height: 20));
            }

            return widgets;
          },
        ),
      );

      // Try to share the PDF directly without saving
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'detailed_receipt_report.pdf',
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
          "View Report",
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

            // Step 1: Group by store name and sum total amount
            Map<String, double> storeTotals = {};

            for (var report in reports) {
              String storeName = report['store_name'] ?? 'Unknown Store';
              double totalAmount = double.tryParse(
                  report['total_amount'].toString()) ?? 0.0;

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
                  "Month: $monthYear",
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
      floatingActionButton: FloatingActionButton(
        onPressed: generateAndDownloadPDF,
        backgroundColor: Colors.green,
        child: Icon(Icons.picture_as_pdf, color: Colors.white),
      ),
    );
  }
}