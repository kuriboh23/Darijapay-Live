// lib/app/presentation/screens/dashboard_screen.dart (FINAL - POLISHED)
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/data/models/expense_model.dart';
import 'package:darijapay_live/app/data/models/group_model.dart';
import 'package:darijapay_live/app/presentation/screens/group_details_screen.dart';
import 'package:darijapay_live/app/presentation/widgets/group_card.dart';
import 'package:darijapay_live/app/presentation/widgets/overall_balance_card.dart';
import 'package:darijapay_live/app/services/auth_service.dart';
import 'package:darijapay_live/app/services/debt_calculator_service.dart';
import 'package:darijapay_live/app/services/firestore_service.dart';
import 'package:darijapay_live/app/presentation/widgets/glassmorphic_container.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  final AuthService authService;
  final FirestoreService firestoreService;

  const DashboardScreen({
    super.key,
    required this.authService,
    required this.firestoreService,
  });
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Services are now passed in via the widget
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final DebtCalculatorService _debtCalculator = DebtCalculatorService();

// New helper method to fetch all expenses for a list of groups
  Future<List<Expense>> _fetchAllExpenses(List<Group> groups) async {
    final List<Future<List<Expense>>> expenseFutures = [];
    for (final group in groups) {
      // .first gets the current value of the stream
      expenseFutures.add(_firestoreService.getExpensesStream(group.id).first);
    }
    final List<List<Expense>> results = await Future.wait(expenseFutures);
    // Flatten the list of lists into a single list of expenses
    return results.expand((expenses) => expenses).toList();
  }

 @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentUserId = _authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Salam, ${_authService.currentUser?.displayName ?? 'User'}!', style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => _authService.signOut())],
      ),
      body: StreamBuilder<List<Group>>(
        stream: _firestoreService.getGroupsStream(),
        builder: (context, groupSnapshot) {
        if (groupSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final groups = groupSnapshot.data ?? [];
        // Fetch all expenses for all groups to calculate overall balance
        return FutureBuilder<List<Expense>>(
          future: _fetchAllExpenses(groups),
          builder: (context, expenseSnapshot) {
            if (expenseSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final allExpenses = expenseSnapshot.data ?? [];
        final overallBalances = _debtCalculator.calculateBalances(allExpenses);
        
        double totalOwedToUser = 0;
        double totalOwedByUser = 0;
        final currentUserBalance = overallBalances[currentUserId] ?? 0.0;
        if (currentUserBalance > 0) totalOwedToUser = currentUserBalance;
        else totalOwedByUser = currentUserBalance.abs();

        // This is a simplified calculation for the overall card.
        // A more accurate way is to sum positive and negative balances separately.
        overallBalances.forEach((uid, balance) {
          if (balance > 0) totalOwedToUser += balance;
          else totalOwedByUser += balance.abs();
        });
        totalOwedToUser = overallBalances.values.where((v) => v > 0).fold(0, (a, b) => a + b);
        final userSpecificTotalBalance = overallBalances[currentUserId] ?? 0.0;


        return ListView(
          padding: const EdgeInsets.only(top: 20, bottom: 80),
          children: [
            OverallBalanceCard(
              totalBalance: userSpecificTotalBalance,
              totalYouAreOwed: userSpecificTotalBalance > 0 ? userSpecificTotalBalance : 0,
              totalYouOwe: userSpecificTotalBalance < 0 ? userSpecificTotalBalance.abs() : 0,
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Your Groups', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            ...groups.map((group) {
              // Re-fetch and calculate for each group individually
              return StreamBuilder<List<Expense>>(
                stream: _firestoreService.getExpensesStream(group.id),
                builder: (context, groupExpenseSnapshot) {
                  if (!groupExpenseSnapshot.hasData) {
                    return const SizedBox.shrink(); // Or a shimmer loader
                  }
                  final groupExpenses = groupExpenseSnapshot.data!;
                  final groupBalances = _debtCalculator.calculateBalances(groupExpenses);
                  final userBalanceInGroup = groupBalances[currentUserId] ?? 0.0;
                  
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GroupDetailsScreen(group: group,firestoreService: FirestoreService(),))),
                    child: GroupCard(
                      groupName: group.name,
                      userBalance: userBalanceInGroup,
                    ),
                  );
                },
              );
            }).toList(),
          ],
        );
      },
      );  
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* Add create group logic */ },
        backgroundColor: AppTheme.primaryAccent,
        child: const Icon(Icons.add, color: AppTheme.textHeadings),
      ),
    );
  }
}
