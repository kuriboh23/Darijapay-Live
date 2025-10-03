// lib/app/presentation/screens/group_details_screen.dart
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/data/models/expense_model.dart';
import 'package:darijapay_live/app/data/models/group_model.dart';
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
      appBar: AppBar(title: Text(widget.group.name, style: const TextStyle(color: AppTheme.textHeadings))),
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpensesStream(widget.group.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No expenses yet.', style: TextStyle(color: AppTheme.textBody)));
          }
          final expenses = snapshot.data!;
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              // We will replace this with a nice ExpenseCard widget later
              return ListTile(
                title: Text(expense.description, style: const TextStyle(color: AppTheme.textHeadings)),
                subtitle: Text('Paid by: ${expense.payerUid.substring(0, 6)}...', style: const TextStyle(color: AppTheme.textBody)),
                trailing: Text('${expense.amount.toStringAsFixed(2)} DH', style: const TextStyle(color: AppTheme.positiveAccent, fontWeight: FontWeight.bold)),
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