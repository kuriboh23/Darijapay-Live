// lib/app/presentation/widgets/overall_balance_card.dart
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/presentation/widgets/glassmorphic_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OverallBalanceCard extends StatelessWidget {
  final double totalBalance;
  final double totalYouAreOwed;
  final double totalYouOwe;

  const OverallBalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalYouAreOwed,
    required this.totalYouOwe,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'DH',
      decimalDigits: 2,
    );
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GlassmorphicContainer(
        width: screenWidth,
        height: 165,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Balance",
                    style: TextStyle(color: AppTheme.textBody, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currencyFormat.format(totalBalance),
                    style: TextStyle(
                      color: totalBalance >= 0
                          ? AppTheme.textHeadings
                          : Colors.orangeAccent,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBalanceRow(
                    label: "You are owed",
                    amount: currencyFormat.format(totalYouAreOwed),
                    color: AppTheme.positiveAccent,
                  ),
                  _buildBalanceRow(
                    label: "You owe",
                    amount: currencyFormat.format(totalYouOwe),
                    color: AppTheme.textBody,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add this helper method inside the OverallBalanceCard class

  Widget _buildBalanceRow({
    required String label,
    required String amount,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textBody, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
