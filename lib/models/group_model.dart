import 'participant_model.dart';
import 'expense_model.dart';

class Group {
  final String id;
  final String name;
  final List<Participant> participants;
  final List<Expense> expenses;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.participants,
    required this.expenses,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'participants': participants.map((p) => p.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      participants: (json['participants'] as List?)
          ?.map((p) => Participant.fromJson(p))
          .toList() ?? [],
      expenses: (json['expenses'] as List?)
          ?.map((e) => Expense.fromJson(e))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}