import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({
    super.key,
    required this.balance,
    required this.accountNumber,
  });

  final String balance;
  final String accountNumber;

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    final displayBalance = _showBalance ? 'KES ${widget.balance}' : 'KES •••••';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A4D8C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Primary Account',
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showBalance = !_showBalance;
                  });
                },
                icon: Icon(
                  _showBalance
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white,
                ),
                tooltip: _showBalance ? 'Hide balance' : 'Show balance',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayBalance,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Account • ${widget.accountNumber}',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
