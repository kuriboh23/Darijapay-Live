// lib/app/data/models/user_model.dart
class AppUser {
  final String uid;
  final String email;
  final String displayName;

  AppUser({required this.uid, required this.email, required this.displayName});

  factory AppUser.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AppUser(
      uid: documentId,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
    );
  }
}