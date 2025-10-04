// lib/app/presentation/screens/group_details_screen.dart
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/data/models/expense_model.dart';
import 'package:darijapay_live/app/data/models/group_model.dart';
import 'package:darijapay_live/app/data/models/app_user.dart';
import 'package:darijapay_live/app/presentation/screens/add_expense_screen.dart';
import 'package:darijapay_live/app/presentation/widgets/expense_card.dart';
import 'package:darijapay_live/app/services/firestore_service.dart';
import 'package:flutter/material.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Group group;
  final FirestoreService firestoreService;

  const GroupDetailsScreen({
    super.key,
    required this.group,
    required this.firestoreService,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  // Use the service instance passed from the parent
  late final FirestoreService _firestoreService = widget.firestoreService;
  late Future<List<AppUser>>
  _groupMembersFuture; // Use AppUser from app_user.dart

  @override
  void initState() {
    super.initState();
    _groupMembersFuture = _firestoreService
        .getUserProfiles(widget.group.memberUids)
        .then(
          (users) => users
              .map(
                (user) => AppUser(
                  uid: user.uid,
                  email: user.email,
                  displayName: user.displayName,
                ),
              )
              .toList(),
        );
    print("Fetching profiles for UIDs: ${widget.group.memberUids}"); // See what UIDs you're asking for
  }
void _navigateToAddExpense() {
  _groupMembersFuture.then((members) {
     print("Navigating to AddExpenseScreen with ${members.length} members."); // See what's being passed
    // --- THE SANITY CHECK ---
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not load group members to add an expense.')),
      );
      return; // Stop execution here
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddExpenseScreen(
            groupId: widget.group.id,
            groupMembers: members,
          ),
        ),
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      body: FutureBuilder<List<AppUser>>(
        future: _groupMembersFuture,
        builder: (context, membersSnapshot) {
          if (membersSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!membersSnapshot.hasData || membersSnapshot.data!.isEmpty) {
            return const Center(child: Text('Could not load group members.'));
          }
          // OPTIMIZATION: Create a map for fast O(1) lookups of member names by UID.
          final groupMembersMap = {
            for (var member in membersSnapshot.data!) member.uid: member,
          };

          return StreamBuilder<List<Expense>>(
            stream: _firestoreService.getExpensesStream(widget.group.id),
            builder: (context, expensesSnapshot) {
              if (expensesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!expensesSnapshot.hasData || expensesSnapshot.data!.isEmpty) {
                return const Center(child: Text('No expenses yet.'));
              }
              final expenses = expensesSnapshot.data!;

              return ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  // Use the map for an efficient lookup.
                  final payerName =
                      groupMembersMap[expense.payerUid]?.displayName ??
                      'Unknown';

                  return ExpenseCard(
                    expense: expense,
                    payerDisplayName: payerName,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        backgroundColor: AppTheme.primaryAccent,
        child: const Icon(Icons.add, color: AppTheme.textHeadings),
      ),
    );
  }
}
