import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/app_theme.dart';
import '../viewmodels/bill_splitting_viewmodel.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  final List<TextEditingController> _participantControllers = [];

  @override
  void initState() {
    super.initState();
    _addParticipantField();
    _addParticipantField();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    for (var controller in _participantControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addParticipantField() {
    setState(() {
      _participantControllers.add(TextEditingController());
    });
  }

  void _removeParticipantField(int index) {
    setState(() {
      _participantControllers[index].dispose();
      _participantControllers.removeAt(index);
    });
  }

  void _createGroup() {
    if (!_formKey.currentState!.validate()) return;

    final participantNames =
        _participantControllers
            .map((controller) => controller.text.trim())
            .where((name) => name.isNotEmpty)
            .toList();

    if (participantNames.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least 2 participants')),
      );
      return;
    }

    final viewModel = context.read<BillSplittingViewModel>();
    viewModel.createGroup(_groupNameController.text.trim(), participantNames);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Group "${_groupNameController.text}" created!'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        actions: [
          TextButton(onPressed: _createGroup, child: const Text('Create')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupNameSection().animate().slideY(begin: 0.3).fadeIn(),
              const SizedBox(height: 32),
              _buildParticipantsSection()
                  .animate()
                  .slideY(begin: 0.3, delay: 200.ms)
                  .fadeIn(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child:
                    ElevatedButton(
                      onPressed: _createGroup,
                      child: const Text('Create Group'),
                    ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group Name',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _groupNameController,
          decoration: InputDecoration(
            hintText: 'e.g., Weekend Trip, Roommates...',
            prefixIcon: const Icon(LucideIcons.users),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a group name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Participants',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addParticipantField,
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(_participantControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                TextFormField(
                  controller: _participantControllers[index],
                  decoration: InputDecoration(
                    hintText: 'Participant ${index + 1} name',
                    prefixIcon: const Icon(LucideIcons.user),
                    suffixIcon:
                        _participantControllers.length > 2
                            ? IconButton(
                              onPressed: () => _removeParticipantField(index),
                              icon: const Icon(LucideIcons.x, size: 16),
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ).animate(delay: (index * 100).ms).slideX(begin: 0.3).fadeIn(),
          );
        }),
      ],
    );
  }
}
