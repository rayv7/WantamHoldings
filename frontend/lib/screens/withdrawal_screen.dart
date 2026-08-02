import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WithdrawalScreen extends StatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  State<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  String _selectedAccount = 'Primary Savings Account';
  String _withdrawalMethod = 'M-Pesa';
  final TextEditingController _amountController = TextEditingController(
    text: '5000',
  );
  final TextEditingController _pinController = TextEditingController(
    text: '1234',
  );

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingBalance =
        240000 -
        (int.tryParse(
              _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0);

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
            DropdownButtonFormField<String>(
              initialValue: _selectedAccount,
              decoration: InputDecoration(
                labelText: 'Select Account',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Primary Savings Account',
                  child: Text('Primary Savings Account'),
                ),
                DropdownMenuItem(
                  value: 'Business Account',
                  child: Text('Business Account'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _selectedAccount = value ?? _selectedAccount),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Withdrawal Amount',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _withdrawalMethod,
              decoration: InputDecoration(
                labelText: 'Withdrawal Method',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'M-Pesa', child: Text('M-Pesa')),
                DropdownMenuItem(value: 'ATM Cash', child: Text('ATM Cash')),
                DropdownMenuItem(
                  value: 'Bank Branch',
                  child: Text('Bank Branch'),
                ),
              ],
              onChanged: (value) => setState(
                () => _withdrawalMethod = value ?? _withdrawalMethod,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pinController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Transaction PIN',
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance: KES 240,000',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Remaining Balance After Withdrawal: KES $remainingBalance',
                    style: GoogleFonts.poppins(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Withdrawal completed successfully.'),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Confirm Withdrawal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
