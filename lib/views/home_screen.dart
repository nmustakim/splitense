import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_theme.dart';
import '../viewmodels/bill_splitting_viewmodel.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Splitense',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              centerTitle: false,
            ),
            actions: [
              IconButton(
                onPressed: () => _showCreateGroupDialog(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.plus,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ).animate().scale(delay: 300.ms),
              const SizedBox(width: 16),
            ],
          ),
          Consumer<BillSplittingViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (viewModel.groups.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState(context));
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final group = viewModel.groups[index];
                    return _buildGroupCard(context, group, viewModel)
                        .animate(delay: (index * 100).ms)
                        .slideY(begin: 0.3, duration: 400.ms)
                        .fadeIn();
                  }, childCount: viewModel.groups.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withAlpha(8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.users,
              size: 64,
              color: AppTheme.primaryBlue,
            ),
          ).animate().scale(delay: 200.ms),
          const SizedBox(height: 24),
          Text(
            'No Groups Yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 8),
          Text(
            'Create your first group to start\nsplitting bills with friends',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ).animate().fadeIn(delay: 600.ms),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showCreateGroupDialog(context),
            icon: const Icon(LucideIcons.plus),
            label: const Text('Create Group'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ).animate().slideY(begin: 0.5, delay: 800.ms),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    group,
    BillSplittingViewModel viewModel,
  ) {
    final totalExpenses = group.expenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          viewModel.selectGroup(group);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GroupDetailScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withAlpha(8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.users,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${group.participants.length} members • ${group.expenses.length} expenses',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(LucideIcons.moreVertical),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            onTap:
                                () => _confirmDelete(
                                  context,
                                  group.id,
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
                                Text('Delete Group'),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Spent',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        Text(
                          '\$${totalExpenses.toStringAsFixed(2)}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(LucideIcons.chevronRight, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
  }

  void _confirmDelete(
    BuildContext context,
    String groupId,
    BillSplittingViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Group'),
            content: const Text(
              'Are you sure you want to delete this group? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  viewModel.deleteGroup(groupId);
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
