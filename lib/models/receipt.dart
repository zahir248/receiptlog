class Receipt {
  final int id;
  final int userId;
  final String storeName;
  final double totalAmount;
  final DateTime date;

  Receipt({
    required this.id,
    required this.userId,
    required this.storeName,
    required this.totalAmount,
    required this.date,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      userId: json['user_id'],
      storeName: json['store_name'],
      totalAmount: (json['total_amount'] is String)
          ? double.parse(json['total_amount']) // Convert string to double
          : (json['total_amount'] as num).toDouble(), // Convert num to double
      date: DateTime.parse(json['date']),
    );
  }

  // Convert Receipt object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_name': storeName,
      'total_amount': totalAmount,
      'date': date,
    };
  }
}
