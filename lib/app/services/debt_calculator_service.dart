// lib/app/services/debt_calculator_service.dart
import 'package:darijapay_live/app/data/models/expense_model.dart';

class DebtCalculatorService {
  /// Calculates the net balance for each user in a list of expenses.
  /// Returns a map where the key is the user's UID and the value is their balance.
  /// A positive value means the user is owed money.
  /// A negative value means the user owes money.
  Map<String, double> calculateBalances(List<Expense> expenses) {
    final Map<String, double> balances = {};

    if (expenses.isEmpty) {
      return balances;
    }

    for (final expense in expenses) {
      final payerUid = expense.payerUid;
      final amount = expense.amount;
      final participants = expense.participantUids;

      if (participants.isEmpty) continue;

      // Initialize balances for users if they don't exist yet
      balances.putIfAbsent(payerUid, () => 0.0);
      for (final participant in participants) {
        balances.putIfAbsent(participant, () => 0.0);
      }
      
      final sharePerPerson = amount / participants.length;

      // The payer is credited the full amount they paid
      balances[payerUid] = balances[payerUid]! + amount;

      // Each participant is debited their share
      for (final participant in participants) {
        balances[participant] = balances[participant]! - sharePerPerson;
      }
    }
    return balances;
  }
}