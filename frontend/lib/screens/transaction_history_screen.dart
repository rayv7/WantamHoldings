import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/transaction_tile.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      const TransactionModel(
        type: 'Transfer',
        merchant: 'Nancy Wanjiru',
        date: '30 Jul',
        time: '09:15',
        amount: '-KES 7,500',
        status: 'Completed',
      ),
      const TransactionModel(
        type: 'Deposit',
        merchant: 'Salary',
        date: '29 Jul',
        time: '08:00',
        amount: '+KES 55,000',
        status: 'Completed',
      ),
      const TransactionModel(
        type: 'Withdrawal',
        merchant: 'ATM',
        date: '28 Jul',
        time: '18:30',
        amount: '-KES 3,000',
        status: 'Completed',
      ),
      const TransactionModel(
        type: 'Transfer',
        merchant: 'Mark Otieno',
        date: '27 Jul',
        time: '13:45',
        amount: '-KES 2,500',
        status: 'Pending',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE3EEF1),
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: const Color(0xFFE3EEF1),
        foregroundColor: const Color(0xFF0A4D8C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'All Transactions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const SearchFilterBar(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) =>
                    TransactionTile(transaction: transactions[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
