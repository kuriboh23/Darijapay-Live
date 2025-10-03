// lib/app/presentation/widgets/expense_card.dart
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/data/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  const ExpenseCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.description,
              style: const TextStyle(color: AppTheme.textHeadings, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paid by ${expense.payerDisplayName}',
                      style: const TextStyle(color: AppTheme.textBody, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().format(expense.timestamp.toDate()), // Format the date
                      style: const TextStyle(color: AppTheme.textBody, fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  '${expense.amount.toStringAsFixed(2)} DH',
                  style: const TextStyle(color: AppTheme.positiveAccent, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}