// lib/app/presentation/widgets/group_card.dart (FINAL - WITH BALANCES)
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/presentation/widgets/glassmorphic_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupCard extends StatelessWidget {
  final String groupName;
  final double userBalance; // The user's net balance for this specific group

  const GroupCard({
    super.key,
    required this.groupName,
    required this.userBalance,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'DH', decimalDigits: 2);
    final screenWidth = MediaQuery.of(context).size.width;

    String balanceText;
    Color balanceColor;
    String statusText;

    if (userBalance.abs() < 0.01) { // Check if balance is effectively zero
      statusText = 'Settled up';
      balanceText = '';
      balanceColor = AppTheme.textBody;
    } else if (userBalance > 0) {
      statusText = 'You are owed';
      balanceText = currencyFormat.format(userBalance);
      balanceColor = AppTheme.positiveAccent;
    } else {
      statusText = 'You owe';
      balanceText = currencyFormat.format(userBalance.abs());
      balanceColor = Colors.orangeAccent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GlassmorphicContainer(
        width: screenWidth,
        height: 100,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Group Name
              Text(
                groupName,
                style: const TextStyle(
                  color: AppTheme.textHeadings,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Right side: Balance
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    statusText,
                    style: const TextStyle(color: AppTheme.textBody, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  if (balanceText.isNotEmpty)
                    Text(
                      balanceText,
                      style: TextStyle(
                        color: balanceColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}