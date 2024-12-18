import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import '../models/item.dart';
import '../providers/bill_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ViewBillScreen extends StatelessWidget {
  final int billId;

  const ViewBillScreen({Key? key, required this.billId}) : super(key: key);

  Future<void> _printBill(BuildContext context, String customerName, String contactNumber, double totalAmount, List<Item> items) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Bill for: $customerName',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Contact: $contactNumber'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Items:',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return pw.Text('${item.itemName} - ${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}');
                },
              ),
              pw.Divider(),
              pw.Text(
                'Total: \$${totalAmount.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);
    final bill = billProvider.bills.firstWhere((bill) => bill.id == billId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'View Bill',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              final items = await billProvider.getItemsByBillId(billId);
              if (items != null) {
                _printBill(context, bill.customerName, bill.contactNumber, bill.totalAmount, items);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: billProvider.getItemsByBillId(billId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          final items = snapshot.data as List<Item>?;

          if (items == null || items.isEmpty) {
            return const Center(
              child: Text(
                'No items added to this bill yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Information
                _buildSectionTitle('Customer Information'),
                const SizedBox(height: 8),
                _buildInfoText('Customer: ${bill.customerName}'),
                _buildInfoText('Contact: ${bill.contactNumber}'),
                const SizedBox(height: 20),

                // Item List
                _buildSectionTitle('Items'),
                const SizedBox(height: 8),
                ...items.map((item) {
                  return _buildInfoText('${item.itemName} - ${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}');
                }).toList(),
                const SizedBox(height: 20),

                // Total Amount
                _buildInfoText('Total: \$${bill.totalAmount.toStringAsFixed(2)}', isTotal: true),
                const SizedBox(height: 20),

                // Switch for Paid Status
                const Divider(),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text(
                    'Paid Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  value: bill.status == 'Paid',
                  onChanged: (bool value) async {
                    final newStatus = value ? 'Paid' : 'Unpaid';
                    final updated = await billProvider.updateBillStatus(bill.id!, newStatus);
                    if (updated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bill status updated to $newStatus')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update bill status')),
                      );
                    }
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildInfoText(String text, {bool isTotal = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isTotal ? 18 : 16,
        fontWeight: FontWeight.w500,
        color: isTotal ? Colors.green : Colors.black,
      ),
    );
  }
}
