class ReceiptItem {
  final int id;
  final int receiptId;
  final String itemName;
  final int quantity;
  final double price;

  ReceiptItem({
    required this.id,
    required this.receiptId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  // Convert JSON to ReceiptItem object
  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      id: json['id'],
      receiptId: json['receipt_id'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }

  // Convert ReceiptItem object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receipt_id': receiptId,
      'item_name': itemName,
      'quantity': quantity,
      'price': price,
    };
  }
}
