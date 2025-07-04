import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_theme.dart';
import '../viewmodels/bill_splitting_viewmodel.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedPayerId;
  final Set<String> _selectedParticipants = {};

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _addExpense() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPayerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select who paid')));
      return;
    }
    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who this expense is for')),
      );
      return;
    }

    final viewModel = context.read<BillSplittingViewModel>();
    viewModel.addExpense(
      _descriptionController.text.trim(),
      double.parse(_amountController.text),
      _selectedPayerId!,
      _selectedParticipants.toList(),
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense added successfully!'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BillSplittingViewModel>(
      builder: (context, viewModel, child) {
        final group = viewModel.currentGroup;
        if (group == null) {
          return const Scaffold(body: Center(child: Text('Group not found')));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Expense'),
            actions: [
              TextButton(onPressed: _addExpense, child: const Text('Save')),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExpenseDetailsSection()
                      .animate()
                      .slideY(begin: 0.3)
                      .fadeIn(),
                  const SizedBox(height: 24),
                  _buildPayerSection(
                    group,
                  ).animate().slideY(begin: 0.3, delay: 200.ms).fadeIn(),
                  const SizedBox(height: 24),
                  _buildParticipantsSection(
                    group,
                  ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child:
                        ElevatedButton(
                          onPressed: _addExpense,
                          child: const Text('Add Expense'),
                        ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpenseDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense Details',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'What was this expense for?',
            prefixIcon: const Icon(LucideIcons.fileText),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount',
            hintText: '0.00',
            prefixIcon: const Icon(LucideIcons.dollarSign),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPayerSection(group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Who Paid?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...group.participants.map<Widget>((participant) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<String>(
              title: Text(participant.name),
              value: participant.id,
              groupValue: _selectedPayerId,
              onChanged: (value) {
                setState(() {
                  _selectedPayerId = value;
                });
              },
              activeColor: AppTheme.primaryBlue,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildParticipantsSection(group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Split Between',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedParticipants.length ==
                      group.participants.length) {
                    _selectedParticipants.clear();
                  } else {
                    _selectedParticipants.clear();
                    _selectedParticipants.addAll(
                      group.participants.map((p) => p.id),
                    );
                  }
                });
              },
              child: Text(
                _selectedParticipants.length == group.participants.length
                    ? 'Deselect All'
                    : 'Select All',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...group.participants.map<Widget>((participant) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: CheckboxListTile(
              title: Text(participant.name),
              value: _selectedParticipants.contains(participant.id),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedParticipants.add(participant.id);
                  } else {
                    _selectedParticipants.remove(participant.id);
                  }
                });
              },
              activeColor: AppTheme.primaryBlue,
            ),
          );
        }).toList(),
      ],
    );
  }
}
