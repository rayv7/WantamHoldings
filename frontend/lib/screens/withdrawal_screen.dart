import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/admin_store.dart';
import '../core/user_store.dart';
import '../services/api_service.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _amountController.dispose();
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
          content: Text('Account is frozen. Cannot withdraw.'),
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
        await ApiService().withdraw(
          accountNumber: UserStore.accountNumber,
          amount: amountText,
        );
      }
    } catch (_) {}

    final account = AdminStore.getAccountByNumber(UserStore.accountNumber);
    if (account != null) {
      account.balance -= amount;
    }

    UserStore.balance -= amount;
    UserStore.save();

    AdminStore.addTransaction(AdminTransaction(
      id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      type: 'Withdrawal',
      accountNumber: UserStore.accountNumber,
      customerName: UserStore.name,
      amount: amount,
      date: _today(),
      time: _now(),
    ));

    setState(() => _loading = false);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Withdrawal completed successfully.')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final remainingBalance = UserStore.balance -
        (double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFFE3EEF1),
      appBar: AppBar(
        title: const Text('Withdraw Money'),
        backgroundColor: const Color(0xFFE3EEF1),
        foregroundColor: const Color(0xFF0A4D8C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Withdrawal Details',
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
                labelText: 'Withdrawal Amount',
                prefixText: 'KES ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance: ${UserStore.formattedBalance}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Remaining Balance After Withdrawal: KES ${remainingBalance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
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
                    : const Text('Confirm Withdrawal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}