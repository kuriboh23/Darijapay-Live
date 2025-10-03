// lib/app/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:darijapay_live/app/data/models/expense_model.dart';
import 'package:darijapay_live/app/data/models/group_model.dart';
import 'package:darijapay_live/app/data/models/user_model.dart';
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
}) async {
  final user = _authService.currentUser;
  if (user == null) return;

  // For now, we'll assume the current user paid and it's for everyone in the group.
  // We will make this logic much more powerful later.
  final groupDoc = await _db.collection('groups').doc(groupId).get();
  final memberUids = List<String>.from(groupDoc.data()?['memberUids'] ?? []);

  await _db
      .collection('groups')
      .doc(groupId)
      .collection('expenses')
      .add({
    'description': description,
    'amount': amount,
    'payerUid': user.uid,
    'participantUids': memberUids, // Simple logic for now
    'timestamp': Timestamp.now(),
  });
}

// Get a list of user profiles from a list of UIDs
Future<List<AppUser>> getUserProfiles(List<String> uids) async {
  if (uids.isEmpty) return [];
  final userDocs = await _db.collection('users').where(FieldPath.documentId, whereIn: uids).get();
  return userDocs.docs.map((doc) => AppUser.fromFirestore(doc.data(), doc.id)).toList();
}

}