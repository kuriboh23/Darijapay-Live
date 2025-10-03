// lib/app/presentation/widgets/group_card.dart
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/data/models/group_model.dart';
import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(
          group.name,
          style: const TextStyle(
            color: AppTheme.textHeadings,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          '${group.memberUids.length} members',
          style: const TextStyle(color: AppTheme.textBody),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.textBody, size: 16),
      ),
    );
  }
}