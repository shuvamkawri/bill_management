class Item {
  final int? id;
  final int billId;
  final String itemName;
  final int quantity;
  final double unitPrice;

  Item({
    this.id,
    required this.billId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'billId': billId,
      'itemName': itemName,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  Item copyWith({
    int? billId,
    String? itemName,
    int? quantity,
    double? unitPrice,
  }) {
    return Item(
      id: this.id,
      billId: billId ?? this.billId, // Use the passed billId, or retain the current one
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
