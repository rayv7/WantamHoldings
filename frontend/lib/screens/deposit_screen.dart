import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/admin_store.dart';
import '../core/user_store.dart';
import '../services/api_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
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
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    if (AdminStore.isAccountFrozen(UserStore.accountNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account is frozen. Cannot deposit.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      if (ApiService.hasToken) {
        await ApiService().deposit(
          accountNumber: UserStore.accountNumber,
          amount: amountText,
          description: _referenceController.text.trim().isNotEmpty
              ? _referenceController.text.trim()
              : null,
        );
      }
    } catch (_) {}

    final account = AdminStore.getAccountByNumber(UserStore.accountNumber);
    if (account != null) {
      account.balance += amount;
    }

    UserStore.balance += amount;
    UserStore.save();

    AdminStore.addTransaction(AdminTransaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      type: 'Deposit',
      accountNumber: UserStore.accountNumber,
      customerName: UserStore.name,
      amount: amount,
      date: _today(),
      time: _now(),
    ));

    setState(() => _loading = false);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deposit completed successfully.')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3EEF1),
      appBar: AppBar(
        title: const Text('Deposit Money'),
        backgroundColor: const Color(0xFFE3EEF1),
        foregroundColor: const Color(0xFF0A4D8C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deposit Details',
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
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Deposit Amount',
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
                labelText: 'Reference/Description (optional)',
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
                    'Confirmation Summary',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are about to deposit KES ${_amountController.text.isEmpty ? '0' : _amountController.text} to your account.',
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
                    : const Text('Confirm Deposit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}