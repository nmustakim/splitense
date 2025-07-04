class Expense {
  final String id;
  final String description;
  final double amount;
  final String paidById;
  final List<String> sharedWith;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidById,
    required this.sharedWith,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'paidById': paidById,
      'sharedWith': sharedWith,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      description: json['description'],
      amount: json['amount']?.toDouble() ?? 0.0,
      paidById: json['paidById'],
      sharedWith: List<String>.from(json['sharedWith'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
