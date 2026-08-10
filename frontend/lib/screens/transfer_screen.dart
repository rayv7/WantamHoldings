import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/admin_store.dart';
import '../core/user_store.dart';
import '../services/api_service.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _recipientAccountController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _recipientAccountController.dispose();
    _recipientNameController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  String _today() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _now() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    final recipientAccount = _recipientAccountController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (recipientAccount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter recipient account number.')),
      );
      return;
    }
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }
    if (recipientAccount == UserStore.accountNumber) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot transfer to your own account.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (AdminStore.isAccountFrozen(UserStore.accountNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account is frozen. Cannot transfer.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (amount > UserStore.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      if (ApiService.hasToken) {
        await ApiService().transfer(
          senderAccountNumber: UserStore.accountNumber,
          receiverAccountNumber: recipientAccount,
          amount: amountText,
          description: _referenceController.text.trim().isNotEmpty
              ? _referenceController.text.trim()
              : null,
        );
      }
    } catch (_) {}

    final sender = AdminStore.getAccountByNumber(UserStore.accountNumber);
    if (sender != null) {
      sender.balance -= amount;
    }

    final recipient = AdminStore.getAccountByNumber(recipientAccount);
    if (recipient != null) {
      recipient.balance += amount;
    }

    UserStore.balance -= amount;
    UserStore.save();

    AdminStore.addTransaction(AdminTransaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      type: 'Transfer',
      accountNumber: UserStore.accountNumber,
      customerName: UserStore.name,
      amount: amount,
      date: _today(),
      time: _now(),
    ));

    setState(() => _loading = false);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer completed successfully.')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3EEF1),
      appBar: AppBar(
        title: const Text('Transfer Money'),
        backgroundColor: const Color(0xFFE3EEF1),
        foregroundColor: const Color(0xFF0A4D8C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance, color: Color(0xFF0A4D8C)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        UserStore.accountNumber,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Balance: ${UserStore.formattedBalance}',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _recipientAccountController,
              decoration: InputDecoration(
                labelText: 'Recipient Account Number',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _recipientNameController,
              decoration: InputDecoration(
                labelText: 'Recipient Name (optional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: 'KES ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: 'Reference (optional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECF4FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transfer Summary',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Transfer KES ${_amountController.text.isEmpty ? '0' : _amountController.text} to account ${_recipientAccountController.text.isEmpty ? '...' : _recipientAccountController.text}.',
                    style: GoogleFonts.poppins(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Send Money'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}