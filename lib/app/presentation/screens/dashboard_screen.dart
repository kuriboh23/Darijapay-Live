// lib/app/presentation/screens/dashboard_screen.dart (FINAL)
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/data/models/group_model.dart';
import 'package:darijapay_live/app/presentation/widgets/group_card.dart';
import 'package:darijapay_live/app/services/auth_service.dart';
import 'package:darijapay_live/app/services/firestore_service.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  void _showCreateGroupDialog() {
    final TextEditingController groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2a4c4c),
        title: const Text('Create New Group', style: TextStyle(color: AppTheme.textHeadings)),
        content: TextField(
          controller: groupNameController,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textHeadings),
          decoration: const InputDecoration(hintText: 'Group Name', hintStyle: TextStyle(color: AppTheme.textBody)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppTheme.textBody))),
          TextButton(
            onPressed: () {
              if (groupNameController.text.isNotEmpty) {
                _firestoreService.createGroup(groupNameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create', style: TextStyle(color: AppTheme.primaryAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groups', style: TextStyle(color: AppTheme.textHeadings, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => _authService.signOut())],
      ),
      body: StreamBuilder<List<Group>>(
        stream: _firestoreService.getGroupsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppTheme.textBody)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No groups yet.\nTap the + button to create one!', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textBody, fontSize: 18)),
            );
          }

          final groups = snapshot.data!;
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) => GroupCard(group: groups[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateGroupDialog,
        backgroundColor: AppTheme.primaryAccent,
        child: const Icon(Icons.add, color: AppTheme.textHeadings),
      ),
    );
  }
}