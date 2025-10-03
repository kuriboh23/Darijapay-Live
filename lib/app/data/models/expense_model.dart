// lib/app/data/models/expense_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String description;
  final double amount;
  final String payerUid;
  final String payerDisplayName;
  final List<String> participantUids;
  final Timestamp timestamp;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.payerUid,
    required this.payerDisplayName,
    required this.participantUids,
    required this.timestamp,
  });

  factory Expense.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Expense(
      id: documentId,
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      payerUid: data['payerUid'] ?? '',
      participantUids: List<String>.from(data['participantUids'] ?? []),
      timestamp: data['timestamp'] ?? Timestamp.now(),
      payerDisplayName: '',
    );
  }
}