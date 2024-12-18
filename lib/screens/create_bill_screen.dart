import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/bill.dart';
import '../providers/bill_provider.dart';

class CreateBillScreen extends StatefulWidget {
  const CreateBillScreen({Key? key}) : super(key: key);

  @override
  _CreateBillScreenState createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final _customerNameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final List<Item> _items = [];
  double _totalAmount = 0.0;

  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();

  void _addItem() {
    final itemName = _itemNameController.text;
    final quantity = int.tryParse(_quantityController.text);
    final unitPrice = double.tryParse(_unitPriceController.text);

    if (itemName.isEmpty) {
      _showError('Item name cannot be empty.');
      return;
    }
    if (quantity == null || quantity <= 0) {
      _showError('Quantity must be a positive number.');
      return;
    }
    if (unitPrice == null || unitPrice <= 0) {
      _showError('Unit price must be a positive number.');
      return;
    }

    final item = Item(
      billId: 0,
      itemName: itemName,
      quantity: quantity,
      unitPrice: unitPrice,
    );
    setState(() {
      _items.add(item);
      _totalAmount += quantity * unitPrice;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }


  void _saveBill() {
    final customerName = _customerNameController.text;
    final contactNumber = _contactNumberController.text;

    if (customerName.isNotEmpty && contactNumber.isNotEmpty) {
      final bill = Bill(
        customerName: customerName,
        contactNumber: contactNumber,
        totalAmount: _totalAmount,
        status: 'Unpaid',
      );

      final billProvider = Provider.of<BillProvider>(context, listen: false);
      billProvider.addBill(bill, _items);

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Create Bill',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Information Fields
            const Text(
              'Customer Information',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 10),
            _buildTextField(_customerNameController, 'Customer Name'),
            const SizedBox(height: 10),
            _buildTextField(_contactNumberController, 'Contact Number'),

            const SizedBox(height: 20),
            // Item Information Fields
            const Text(
              'Item Information',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 10),
            _buildTextField(_itemNameController, 'Item Name'),
            const SizedBox(height: 10),
            _buildTextField(_quantityController, 'Quantity', isNumber: true),
            const SizedBox(height: 10),
            _buildTextField(_unitPriceController, 'Unit Price', isNumber: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Add Item',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            // Total Amount Display
            Text(
              'Total: \$$_totalAmount',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Save Bill Button
            ElevatedButton(
              onPressed: _saveBill,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Save Bill',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom method to create text fields
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }
}
