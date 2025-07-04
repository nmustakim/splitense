import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/group_model.dart';
import '../models/participant_model.dart';
import '../models/expense_model.dart';

class BillSplittingViewModel extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  List<Group> _groups = [];
  Group? _currentGroup;
  bool _isLoading = false;

  List<Group> get groups => _groups;
  Group? get currentGroup => _currentGroup;
  bool get isLoading => _isLoading;

  BillSplittingViewModel() {
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson = prefs.getStringList('groups') ?? [];
      _groups =
          groupsJson.map((json) => Group.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      debugPrint('Error loading groups: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final groupsJson =
          _groups.map((group) => jsonEncode(group.toJson())).toList();
      await prefs.setStringList('groups', groupsJson);
    } catch (e) {
      debugPrint('Error saving groups: $e');
    }
  }

  void createGroup(String name, List<String> participantNames) {
    final participants =
        participantNames
            .map((name) => Participant(id: _uuid.v4(), name: name))
            .toList();

    final group = Group(
      id: _uuid.v4(),
      name: name,
      participants: participants,
      expenses: [],
      createdAt: DateTime.now(),
    );

    _groups.add(group);
    _currentGroup = group;
    _saveGroups();
    notifyListeners();
  }

  void selectGroup(Group group) {
    _currentGroup = group;
    notifyListeners();
  }

  void addExpense(
    String description,
    double amount,
    String paidById,
    List<String> sharedWith,
  ) {
    if (_currentGroup == null) return;

    final expense = Expense(
      id: _uuid.v4(),
      description: description,
      amount: amount,
      paidById: paidById,
      sharedWith: sharedWith,
      createdAt: DateTime.now(),
    );

    _currentGroup!.expenses.add(expense);
    _calculateBalances();
    _saveGroups();
    notifyListeners();
  }

  void _calculateBalances() {
    if (_currentGroup == null) return;

    for (var participant in _currentGroup!.participants) {
      participant.balance = 0.0;
    }

    for (var expense in _currentGroup!.expenses) {
      final splitAmount = expense.amount / expense.sharedWith.length;

      final payer = _currentGroup!.participants.firstWhere(
        (p) => p.id == expense.paidById,
      );
      payer.balance += expense.amount;

      for (var participantId in expense.sharedWith) {
        final participant = _currentGroup!.participants.firstWhere(
          (p) => p.id == participantId,
        );
        participant.balance -= splitAmount;
      }
    }
  }

  List<Map<String, dynamic>> getSettlements() {
    if (_currentGroup == null) return [];

    final settlements = <Map<String, dynamic>>[];
    final participants = List.from(_currentGroup!.participants);

    participants.sort((a, b) => b.balance.compareTo(a.balance));

    int i = 0;
    int j = participants.length - 1;

    while (i < j) {
      final creditor = participants[i];
      final debtor = participants[j];

      if (creditor.balance <= 0.01) break;
      if (debtor.balance >= -0.01) break;

      final settlementAmount = [
        creditor.balance,
        -debtor.balance,
      ].reduce((a, b) => a < b ? a : b);

      settlements.add({
        'from': debtor.name,
        'to': creditor.name,
        'amount': settlementAmount,
      });

      creditor.balance -= settlementAmount;
      debtor.balance += settlementAmount;

      if (creditor.balance <= 0.01) i++;
      if (debtor.balance >= -0.01) j--;
    }

    return settlements;
  }

  void deleteGroup(String groupId) {
    _groups.removeWhere((group) => group.id == groupId);
    if (_currentGroup?.id == groupId) {
      _currentGroup = null;
    }
    _saveGroups();
    notifyListeners();
  }

  void deleteExpense(String expenseId) {
    if (_currentGroup == null) return;

    _currentGroup!.expenses.removeWhere((expense) => expense.id == expenseId);
    _calculateBalances();
    _saveGroups();
    notifyListeners();
  }

  String generateSummaryText() {
    if (_currentGroup == null) return '';

    final buffer = StringBuffer();
    buffer.writeln('💰 ${_currentGroup!.name} - Expense Summary');
    buffer.writeln('═' * 40);
    buffer.writeln();

    buffer.writeln('👥 Participants:');
    for (var participant in _currentGroup!.participants) {
      buffer.writeln('• ${participant.name}');
    }
    buffer.writeln();

    buffer.writeln('Expenses:');
    double total = 0;
    for (var expense in _currentGroup!.expenses) {
      final payer = _currentGroup!.participants.firstWhere(
        (p) => p.id == expense.paidById,
      );
      buffer.writeln(
        '• ${expense.description}: \$${expense.amount.toStringAsFixed(2)} (paid by ${payer.name})',
      );
      total += expense.amount;
    }
    buffer.writeln('Total: \$${total.toStringAsFixed(2)}');
    buffer.writeln();

    buffer.writeln('Settlements:');
    final settlements = getSettlements();
    if (settlements.isEmpty) {
      buffer.writeln('All settled up!');
    } else {
      for (var settlement in settlements) {
        buffer.writeln(
          '• ${settlement['from']} owes ${settlement['to']}: \$${settlement['amount'].toStringAsFixed(2)}',
        );
      }
    }

    return buffer.toString();
  }
}
