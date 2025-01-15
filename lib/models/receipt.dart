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

  // Convert JSON to Receipt object
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      userId: json['user_id'],
      storeName: json['store_name'],
      totalAmount: (json['total_amount'] as num).toDouble(),
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
      'date': date.toIso8601String(),
    };
  }
}
