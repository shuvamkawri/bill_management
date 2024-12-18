import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/bill.dart';
import '../models/item.dart';

class BillProvider with ChangeNotifier {
  List<Bill> _bills = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Bill> get bills => _bills;

  // Fetch all bills
  Future<void> fetchBills() async {
    final data = await _dbHelper.getBills();
    _bills = data.map((bill) =>
        Bill(
          id: bill['id'],
          customerName: bill['customerName'],
          contactNumber: bill['contactNumber'],
          totalAmount: bill['totalAmount'],
          status: bill['status'],
        )).toList();
    notifyListeners();
  }

  // Fetch items for a particular bill ID
  Future<List<Item>> getItemsByBillId(int billId) async {
    final data = await _dbHelper.getItemsByBillId(billId);
    return data.map((item) =>
        Item(
          id: item['id'],
          billId: item['billId'],
          itemName: item['itemName'],
          quantity: item['quantity'],
          unitPrice: item['unitPrice'],
        )).toList();
  }

  // Add a new bill along with its items
  Future<void> addBill(Bill bill, List<Item> items) async {
    // Save the bill first and get the generated bill ID
    final billId = await _dbHelper.insertBill(bill.toMap());

    // Update the bill ID for each item and add them to the database
    for (var item in items) {
      final newItem = item.copyWith(billId: billId);
      await _dbHelper.insertItem(newItem.toMap());
    }

    // Fetch updated bills list
    await fetchBills();
  }

  // Update bill status
// Update bill status for a specific bill
  Future<bool> updateBillStatus(int billId, String newStatus) async {
    try {
      // Find the bill and update its status in the database
      final bill = _bills.firstWhere((bill) => bill.id == billId);
      final updatedBill = bill.copyWith(status: newStatus);

      // Update the database
      await _dbHelper.updateBill(updatedBill.toMap());

      // Update the local list
      final index = _bills.indexWhere((bill) => bill.id == billId);
      if (index != -1) {
        _bills[index] = updatedBill;
      }

      // Notify listeners
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating bill status: $e');
      return false;
    }
  }
}
