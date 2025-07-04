import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import '../core/app_theme.dart';
import '../viewmodels/bill_splitting_viewmodel.dart';
import 'add_expense_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({super.key});

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
            title: Text(group.name),
            actions: [
              IconButton(
                onPressed: () => _shareGroupSummary(context, viewModel),
                icon: const Icon(LucideIcons.share),
              ),
            ],
          ),
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                _buildSummaryHeader(
                  context,
                  group,
                ).animate().slideY(begin: -0.3).fadeIn(),
                const TabBar(
                  tabs: [
                    Tab(icon: Icon(LucideIcons.receipt), text: 'Expenses'),
                    Tab(icon: Icon(LucideIcons.calculator), text: 'Balances'),
                    Tab(icon: Icon(LucideIcons.creditCard), text: 'Settle'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildExpensesTab(context, group, viewModel),
                      _buildBalancesTab(context, group),
                      _buildSettlementsTab(context, viewModel),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addExpense(context),
            icon: const Icon(LucideIcons.plus),
            label: const Text('Add Expense'),
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
          ).animate().scale(delay: 600.ms),
        );
      },
    );
  }

  Widget _buildSummaryHeader(BuildContext context, group) {
    final totalExpenses = group.expenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    final avgPerPerson =
        group.participants.isNotEmpty
            ? totalExpenses / group.participants.length
            : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.secondaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Spent',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '\$${totalExpenses.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Per Person',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '\$${avgPerPerson.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                icon: LucideIcons.users,
                label: 'Members',
                value: '${group.participants.length}',
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: LucideIcons.receipt,
                label: 'Expenses',
                value: '${group.expenses.length}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(16),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesTab(
    BuildContext context,
    group,
    BillSplittingViewModel viewModel,
  ) {
    if (group.expenses.isEmpty) {
      return _buildEmptyExpenses(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: group.expenses.length,
      itemBuilder: (context, index) {
        final expense = group.expenses[index];
        final payer = group.participants.firstWhere(
          (p) => p.id == expense.paidById,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withAlpha(8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.receipt,
                color: AppTheme.accentTeal,
                size: 20,
              ),
            ),
            title: Text(
              expense.description,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Paid by ${payer.name} • ${expense.sharedWith.length} people',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successGreen,
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(LucideIcons.moreVertical, size: 16),
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          onTap:
                              () => _confirmDeleteExpense(
                                context,
                                expense.id,
                                viewModel,
                              ),
                          child: const Row(
                            children: [
                              Icon(
                                LucideIcons.trash2,
                                size: 16,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ).animate(delay: (index * 100).ms).slideX(begin: 0.3).fadeIn();
      },
    );
  }

  Widget _buildEmptyExpenses(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withAlpha(8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.receipt,
              size: 48,
              color: AppTheme.accentTeal,
            ),
          ).animate().scale(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            'No Expenses Yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 8),
          Text(
            'Add your first expense to get started',
            style: TextStyle(color: Colors.grey[600]),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildBalancesTab(BuildContext context, group) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: group.participants.length,
      itemBuilder: (context, index) {
        final participant = group.participants[index];
        final isPositive = participant.balance > 0;
        final isNeutral = participant.balance.abs() < 0.01;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isNeutral
                      ? Colors.grey.withAlpha(16)
                      : isPositive
                      ? AppTheme.successGreen.withAlpha(16)
                      : AppTheme.errorRed.withAlpha(16),
              child: Text(
                participant.name[0].toUpperCase(),
                style: TextStyle(
                  color:
                      isNeutral
                          ? Colors.grey
                          : isPositive
                          ? AppTheme.successGreen
                          : AppTheme.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              participant.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              isNeutral
                  ? 'All settled up'
                  : isPositive
                  ? 'Gets back'
                  : 'Owes',
              style: TextStyle(
                color:
                    isNeutral
                        ? Colors.grey
                        : isPositive
                        ? AppTheme.successGreen
                        : AppTheme.errorRed,
              ),
            ),
            trailing: Text(
              isNeutral
                  ? '\$0.00'
                  : '\$${participant.balance.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    isNeutral
                        ? Colors.grey
                        : isPositive
                        ? AppTheme.successGreen
                        : AppTheme.errorRed,
              ),
            ),
          ),
        ).animate(delay: (index * 100).ms).slideX(begin: 0.3).fadeIn();
      },
    );
  }

  Widget _buildSettlementsTab(
    BuildContext context,
    BillSplittingViewModel viewModel,
  ) {
    final settlements = viewModel.getSettlements();

    if (settlements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withAlpha(8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.checkCircle,
                size: 48,
                color: AppTheme.successGreen,
              ),
            ).animate().scale(delay: 200.ms),
            const SizedBox(height: 16),
            Text(
              'All Settled Up!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.successGreen,
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Everyone has paid their share',
              style: TextStyle(color: Colors.grey[600]),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: settlements.length,
      itemBuilder: (context, index) {
        final settlement = settlements[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.errorRed.withAlpha(8),
                  child: Text(
                    settlement['from'][0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.errorRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settlement['from'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'owes ${settlement['to']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.arrowRight, color: Colors.grey),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppTheme.successGreen.withAlpha(8),
                  child: Text(
                    settlement['to'][0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '\$${settlement['amount'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: (index * 100).ms).slideX(begin: 0.3).fadeIn();
      },
    );
  }

  void _addExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
  }

  void _shareGroupSummary(
    BuildContext context,
    BillSplittingViewModel viewModel,
  ) {
    final summary = viewModel.generateSummaryText();
    Share.share(summary, subject: 'Group Expense Summary');
  }

  void _confirmDeleteExpense(
    BuildContext context,
    String expenseId,
    BillSplittingViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Expense'),
            content: const Text(
              'Are you sure you want to delete this expense?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  viewModel.deleteExpense(expenseId);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
