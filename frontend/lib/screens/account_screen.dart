import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/routes.dart';
import '../core/user_store.dart';
import '../widgets/quick_action_button.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    final balanceText = _showBalance
        ? UserStore.formattedBalance
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
                  _infoRow('Customer Name', UserStore.name),
                  _infoRow('Account Number', UserStore.accountNumber),
                  _infoRow('Account Type', UserStore.accountType),
                  _infoRow('Branch Name', UserStore.branch),
                  _infoRow('Available Balance', balanceText),
                  _infoRow('Current Balance', balanceText),
                  _infoRow('Account Status', UserStore.accountStatus),
                  _infoRow('Date Opened', UserStore.openedOn),
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
                      () => Routes.pushToDeposit(context),
                    ),
                    (
                      Icons.arrow_upward,
                      'Withdraw',
                      () => Routes.pushToWithdrawal(context),
                    ),
                    (
                      Icons.swap_horiz,
                      'Transfer',
                      () => Routes.pushToTransfer(context),
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
