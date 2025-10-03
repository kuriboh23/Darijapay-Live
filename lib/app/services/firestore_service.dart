// lib/app/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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
}