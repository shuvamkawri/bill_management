class Bill {
  final int? id; // Optional
  final String customerName;
  final String contactNumber;
  final double totalAmount;
  final String status;

  Bill({
    this.id, // Optional
    required this.customerName,
    required this.contactNumber,
    required this.totalAmount,
    required this.status,
  });

  Bill copyWith({
    int? id,
    String? customerName,
    String? contactNumber,
    double? totalAmount,
    String? status,
  }) {
    return Bill(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      contactNumber: contactNumber ?? this.contactNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'contactNumber': contactNumber,
      'totalAmount': totalAmount,
      'status': status,
    };
  }
}


