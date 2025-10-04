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
          if (!groupSnapshot.hasData || groupSnapshot.data!.isEmpty) {
            return const Center(child: Text("No groups yet. Tap + to create one."));
          }
          final groups = groupSnapshot.data!;

          // Now that we have groups, use a FutureBuilder to fetch all their expenses
          return FutureBuilder<List<Expense>>(
            future: _fetchAllExpenses(groups),
            builder: (context, expenseSnapshot) {
              if (expenseSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator()); // Show loading while expenses are fetched
              }
              
              final allExpenses = expenseSnapshot.data ?? [];
              final balances = _debtCalculator.calculateBalances(allExpenses);
              
              double totalOwedToUser = 0;
              double totalOwedByUser = 0;

              balances.forEach((uid, balance) {
                if (uid == currentUserId) {
                  if (balance > 0) totalOwedToUser += balance;
                  else totalOwedByUser += balance.abs();
                }
              });

              return ListView(
                padding: const EdgeInsets.only(top: 20, bottom: 80),
                children: [
                  OverallBalanceCard(
                    totalBalance: totalOwedToUser - totalOwedByUser,
                    totalYouAreOwed: totalOwedToUser,
                    totalYouOwe: totalOwedByUser,
                  ),
                  const SizedBox(height: 32),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Your Groups', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  ...groups.map((group) {
                    // We will upgrade the GroupCard to show balances next
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GroupDetailsScreen(group: group,firestoreService: FirestoreService(),))),
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: GlassmorphicContainer(
                      width: screenWidth,
                      height: 100,
                      child: Center(
                        child: Text(group.name, style: const TextStyle(color: AppTheme.textHeadings, fontSize: 20)),
                      ),
                    ),
                  ),
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
