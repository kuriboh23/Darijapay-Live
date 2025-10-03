// lib/app/data/models/group_model.dart
class Group {
  final String id;
  final String name;
  final List<String> memberUids;

  Group({required this.id, required this.name, required this.memberUids});

  // Factory constructor to create a Group from a Firestore document
  factory Group.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Group(
      id: documentId,
      name: data['name'] ?? '',
      memberUids: List<String>.from(data['memberUids'] ?? []),
    );
  }
}