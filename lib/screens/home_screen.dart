import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import 'create_bill_screen.dart';
import 'view_bill_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Bills',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateBillScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: billProvider.fetchBills(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return const Center(child: CircularProgressIndicator());
          }

          if (billProvider.bills.isEmpty) {
            return const Center(
              child: Text(
                'No bills available. Create a new bill!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: billProvider.bills.length,
            itemBuilder: (context, index) {
              final bill = billProvider.bills[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    child: const Icon(Icons.receipt_long, color: Colors.blueAccent),
                  ),
                  title: Text(
                    bill.customerName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: \$${bill.totalAmount}',
                        style: const TextStyle(fontSize: 14, color: Colors.green),
                      ),
                      Text(
                        'Status: ${bill.status}',
                        style: TextStyle(
                          fontSize: 14,
                          color: bill.status == 'Paid' ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewBillScreen(billId: bill.id!),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );

  }
}
