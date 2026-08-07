import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/admin_store.dart';
import '../core/user_store.dart';
import '../models/transaction.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/transaction_tile.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = AdminStore.transactions
        .where((t) => t.accountNumber == UserStore.accountNumber)
        .map((t) {
      final sign = t.type == 'Deposit' ? '+' : '-';
      return TransactionModel(
        type: t.type,
        merchant: t.customerName,
        date: t.date,
        time: t.time,
        amount: '$sign${t.formattedAmount}',
        status: t.status,
      );
    }).toList();

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
