import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/account.dart';
import '../widgets/quick_action_button.dart';
import 'deposit_screen.dart';
import 'transfer_screen.dart';
import 'withdrawal_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    final account = AccountModel(
      customerName: 'Brian Ochieng',
      accountNumber: '0123456789',
      accountType: 'Savings Account',
      branchName: 'Westlands Branch',
      availableBalance: 'KES 240,000',
      currentBalance: 'KES 240,000',
      status: 'Active',
      openedOn: '14 Jan 2022',
    );

    final balanceText = _showBalance ? account.availableBalance : 'KES •••••';
    final currentBalanceText = _showBalance
        ? account.currentBalance
        : 'KES •••••';

    return Scaffold(
      backgroundColor: const Color(0xFFE3EEF1),
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: const Color(0xFFE3EEF1),
        foregroundColor: const Color(0xFF0A4D8C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _infoRow('Customer Name', account.customerName),
                  _infoRow('Account Number', account.accountNumber),
                  _infoRow('Account Type', account.accountType),
                  _infoRow('Branch Name', account.branchName),
                  _infoRow('Available Balance', balanceText),
                  _infoRow('Current Balance', currentBalanceText),
                  _infoRow('Account Status', account.status),
                  _infoRow('Date Opened', account.openedOn),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showBalance = !_showBalance;
                        });
                      },
                      icon: Icon(
                        _showBalance
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      label: Text(
                        _showBalance ? 'Hide balances' : 'Show balances',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Quick Actions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final actions = [
                    (
                      Icons.description_outlined,
                      'Statement',
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Statement will be ready shortly.'),
                          ),
                        );
                      },
                    ),
                    (
                      Icons.arrow_downward,
                      'Deposit',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DepositScreen(),
                        ),
                      ),
                    ),
                    (
                      Icons.arrow_upward,
                      'Withdraw',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WithdrawalScreen(),
                        ),
                      ),
                    ),
                    (
                      Icons.swap_horiz,
                      'Transfer',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransferScreen(),
                        ),
                      ),
                    ),
                  ];

                  final action = actions[index];

                  return SizedBox(
                    width: 68,
                    child: QuickActionButton(
                      icon: action.$1,
                      label: action.$2,
                      compact: true,
                      onTap: action.$3,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey[700])),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
