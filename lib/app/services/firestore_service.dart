// lib/app/services/firestore_service.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darijapay_live/app/data/models/app_user.dart';
import 'package:darijapay_live/app/data/models/expense_model.dart';
import 'package:darijapay_live/app/data/models/group_model.dart';
import 'package:darijapay_live/app/services/auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Get a live stream of groups for the current user
  Stream<List<Group>> getGroupsStream() {
    final user = _authService.currentUser;
    if (user == null) {
      return Stream.value([]); // Return empty stream if no user
    }

    return _db
        .collection('groups')
        // Query for groups where the 'memberUids' array contains the current user's ID
        .where('memberUids', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Group.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Create a new group
  Future<void> createGroup(String groupName) async {
    final user = _authService.currentUser;
    if (user == null) return;

    await _db.collection('groups').add({
      'name': groupName,
      'memberUids': [user.uid], // The creator is the first member
      'createdAt': Timestamp.now(),
    });
  }

  // Get a live stream of expenses for a specific group
Stream<List<Expense>> getExpensesStream(String groupId) {
  return _db
      .collection('groups')
      .doc(groupId)
      .collection('expenses')
      .orderBy('timestamp', descending: true) // Show newest first
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Expense.fromFirestore(doc.data(), doc.id))
          .toList());
}

// Add a new expense to a group's sub-collection
Future<void> addExpenseToGroup({
  required String groupId,
  required String description,
  required double amount,
  required String payerUid,
  required List<String> participantUids,
}) async {
  if (participantUids.isEmpty) return;

  await _db
      .collection('groups')
      .doc(groupId)
      .collection('expenses')
      .add({
    'description': description,
    'amount': amount,
    'payerUid': payerUid,
    'participantUids': participantUids,
    'timestamp': Timestamp.now(),
  });
}

// Get a list of user profiles from a list of UIDs
Future<List<AppUser>> getUserProfiles(List<String> uids) async {
  if (uids.isEmpty) return [];
  final userDocs = await _db.collection('users').where(FieldPath.documentId, whereIn: uids).get();
  print("Found ${userDocs.docs.length} user documents."); // See how many documents Firestore returned
  return userDocs.docs.map((doc) => AppUser.fromFirestore(doc.data(), doc.id)).toList();
}

// New method to get ALL expenses from a list of groups
Stream<List<Expense>> getAllExpensesForUserGroups(List<Group> groups) {
  if (groups.isEmpty) {
    return Stream.value([]);
  }

  final controller = StreamController<List<Expense>>();
  final List<Expense> allExpenses = [];
  int streamsFinished = 0;

  for (final group in groups) {
    getExpensesStream(group.id).listen((expenses) {
      // This logic is a bit tricky: it handles updates from multiple streams
      // For simplicity, we'll just add them. A more robust solution might use RxDart.
      allExpenses.addAll(expenses);
    }, onDone: () {
      streamsFinished++;
      if (streamsFinished == groups.length) {
        controller.add(allExpenses);
        controller.close();
      }
    });
  }
  
  // A simplified approach for the MVP:
  // We'll combine streams as they come in.
  // NOTE: This might lead to duplicate displays on rapid updates, but is fine for now.
  List<Stream<List<Expense>>> streams = groups.map((g) => getExpensesStream(g.id)).toList();
  
  // A better approach for the MVP (using asyncMap to handle fetching)
  // We'll just fetch all expenses for now when the groups stream updates.
  // This is less "real-time" for the overall balance, but much simpler and more reliable.
  // We can upgrade to a complex stream merger later.
  return Stream.value([]); // We will handle this directly in the dashboard for now.
}

}