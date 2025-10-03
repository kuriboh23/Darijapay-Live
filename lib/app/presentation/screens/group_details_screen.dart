// lib/app/presentation/screens/group_details_screen.dart
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/data/models/expense_model.dart';
import 'package:darijapay_live/app/data/models/group_model.dart';
import 'package:darijapay_live/app/data/models/user_model.dart';
import 'package:darijapay_live/app/presentation/widgets/expense_card.dart';
import 'package:darijapay_live/app/services/firestore_service.dart';
import 'package:flutter/material.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Group group;
  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<AppUser>> _groupMembersFuture;

  @override
  void initState() {
    super.initState();
    _groupMembersFuture = _firestoreService.getUserProfiles(widget.group.memberUids);
  }

  void _showAddExpenseDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a4c4c),
        title: const Text('Add New Expense', style: TextStyle(color: AppTheme.textHeadings)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textHeadings),
              decoration: const InputDecoration(hintText: 'Description', hintStyle: TextStyle(color: AppTheme.textBody)),
            ),
            TextField(
              controller: amountController,
              style: const TextStyle(color: AppTheme.textHeadings),
              decoration: const InputDecoration(hintText: 'Amount (DH)', hintStyle: TextStyle(color: AppTheme.textBody)),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final description = descriptionController.text.trim();
              final amount = double.tryParse(amountController.text);
              if (description.isNotEmpty && amount != null && amount > 0) {
                _firestoreService.addExpenseToGroup(
                  groupId: widget.group.id,
                  description: description,
                  amount: amount,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: AppTheme.primaryAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      body: FutureBuilder<List<AppUser>>(
        future: _groupMembersFuture,
        builder: (context, membersSnapshot) {
          if (!membersSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final groupMembers = membersSnapshot.data!;

          return StreamBuilder<List<Expense>>(
            stream: _firestoreService.getExpensesStream(widget.group.id),
            builder: (context, expensesSnapshot) {
              if (!expensesSnapshot.hasData) return const Center(child: CircularProgressIndicator());
              if (expensesSnapshot.data!.isEmpty) return const Center(child: Text('No expenses yet.'));

              final expenses = expensesSnapshot.data!;
              
              // Now, let's enrich the expenses with display names
              final enrichedExpenses = expenses.map((expense) {
                final payerName = groupMembers
                    .firstWhere((m) => m.uid == expense.payerUid, orElse: () => AppUser(uid: '', email: '', displayName: 'Unknown'))
                    .displayName;
                
                // This is a temporary way to update the model.
                // We need to refactor the Expense model to allow this.
                // Let's create a new temporary object for display.
                return Expense(
                  id: expense.id,
                  description: expense.description,
                  amount: expense.amount,
                  payerUid: expense.payerUid,
                  participantUids: expense.participantUids,
                  timestamp: expense.timestamp,
                  payerDisplayName: payerName, // The enriched data!
                );
              }).toList();

              return ListView.builder(
                itemCount: enrichedExpenses.length,
                itemBuilder: (context, index) {
                  return ExpenseCard(expense: enrichedExpenses[index]);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: AppTheme.primaryAccent,
        child: const Icon(Icons.add, color: AppTheme.textHeadings),
      ),
    );
  }
}