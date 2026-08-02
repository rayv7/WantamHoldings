import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/account.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = [
      const AccountModel(
        customerName: 'Brian Ochieng',
        accountNumber: '0123456789',
        accountType: 'Savings',
        branchName: 'Westlands',
        availableBalance: 'KES 240,000',
        currentBalance: 'KES 240,000',
        status: 'Active',
        openedOn: '14 Jan 2022',
      ),
      const AccountModel(
        customerName: 'Ann Wanjiru',
        accountNumber: '0987654321',
        accountType: 'Current',
        branchName: 'CBD',
        availableBalance: 'KES 520,000',
        currentBalance: 'KES 510,000',
        status: 'Active',
        openedOn: '03 Mar 2021',
      ),
      const AccountModel(
        customerName: 'Peter Kamau',
        accountNumber: '0555666777',
        accountType: 'Savings',
        branchName: 'Mombasa',
        availableBalance: 'KES 85,000',
        currentBalance: 'KES 85,000',
        status: 'Active',
        openedOn: '22 Aug 2023',
      ),
      const AccountModel(
        customerName: 'Mary Akinyi',
        accountNumber: '0444333222',
        accountType: 'Current',
        branchName: 'Kisumu',
        availableBalance: 'KES 1,200,000',
        currentBalance: 'KES 1,180,000',
        status: 'Active',
        openedOn: '10 Nov 2020',
      ),
      const AccountModel(
        customerName: 'James Mwangi',
        accountNumber: '0777888999',
        accountType: 'Savings',
        branchName: 'Westlands',
        availableBalance: 'KES 15,000',
        currentBalance: 'KES 15,000',
        status: 'Frozen',
        openedOn: '05 Jun 2024',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE3EEF1),
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A4D8C),
          ),
        ),
        backgroundColor: const Color(0xFFE3EEF1),
        foregroundColor: const Color(0xFF0A4D8C),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF0A4D8C),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Management',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${accounts.length} accounts found',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return _buildAccountCard(account);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(AccountModel account) {
    final statusColor = account.status == 'Active'
        ? const Color(0xFF1F8A5C)
        : const Color(0xFFB5551F);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                account.customerName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  account.status,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _row('Account', account.accountNumber),
          _row('Type', account.accountType),
          _row('Branch', account.branchName),
          _row('Balance', account.availableBalance),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1F1F1F),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}