class Participant {
  final String id;
  final String name;
  double balance;

  Participant({
    required this.id,
    required this.name,
    this.balance = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      name: json['name'],
      balance: json['balance']?.toDouble() ?? 0.0,
    );
  }
}