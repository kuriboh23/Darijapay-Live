// lib/app/presentation/screens/add_expense_screen.dart
import 'package:darijapay_live/app/config/theme.dart';
import 'package:darijapay_live/app/data/models/app_user.dart';
import 'package:darijapay_live/app/presentation/widgets/custom_text_field.dart';
import 'package:darijapay_live/app/services/auth_service.dart';
import 'package:darijapay_live/app/services/firestore_service.dart';
import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;
  final List<AppUser> groupMembers;

  const AddExpenseScreen({
    super.key,
    required this.groupId,
    required this.groupMembers,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _authService = AuthService();
  
  late String _payerUid;
  late Set<String> _participantUids;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default state: The current user paid for everyone
    _payerUid = _authService.currentUser!.uid;
    _participantUids = widget.groupMembers.map((m) => m.uid).toSet();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitExpense() async {
    final description = _descriptionController.text.trim();
    final amount = double.tryParse(_amountController.text);

    if (description.isNotEmpty && amount != null && amount > 0 && _participantUids.isNotEmpty) {
      setState(() => _isLoading = true);
      await _firestoreService.addExpenseToGroup(
        groupId: widget.groupId,
        description: description,
        amount: amount,
        payerUid: _payerUid,
        participantUids: _participantUids.toList(),
      );
      if (mounted) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select at least one participant.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Expense')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(controller: _descriptionController, hintText: 'Description'),
            const SizedBox(height: 16),
            CustomTextField(controller: _amountController, hintText: 'Amount (DH)', keyboardType: TextInputType.numberWithOptions(decimal: true)),
            
            const SizedBox(height: 32),
            const Text('Paid by', style: TextStyle(color: AppTheme.textBody, fontSize: 16)),
            _buildPayerSelector(),
            
            const SizedBox(height: 24),
            const Text('For whom?', style: TextStyle(color: AppTheme.textBody, fontSize: 16)),
            _buildParticipantsSelector(),

            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitExpense,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryAccent, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Add Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPayerSelector() {
    return DropdownButtonFormField<String>(
      value: _payerUid,
      isExpanded: true,
      onChanged: (newValue) => setState(() => _payerUid = newValue!),
      items: widget.groupMembers.map((user) {
        return DropdownMenuItem<String>(
          value: user.uid,
          child: Text(user.displayName, style: const TextStyle(color: AppTheme.textHeadings)),
        );
      }).toList(),
    );
  }

  Widget _buildParticipantsSelector() {
    return Column(
      children: widget.groupMembers.map((user) {
        return CheckboxListTile(
          title: Text(user.displayName, style: const TextStyle(color: AppTheme.textHeadings)),
          value: _participantUids.contains(user.uid),
          activeColor: AppTheme.primaryAccent,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _participantUids.add(user.uid);
              } else {
                _participantUids.remove(user.uid);
              }
            });
          },
        );
      }).toList(),
    );
  }
}