import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/loan.dart';

class ActiveLoanCard extends StatelessWidget {
  const ActiveLoanCard({super.key, required this.loan});

  final ActiveLoan loan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFECF4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loan.type,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _detailRow('Original Amount', loan.originalAmount),
          _detailRow('Outstanding Balance', loan.outstandingBalance),
          _detailRow('Monthly Installment', loan.monthlyInstallment),
          _detailRow('Next Payment', loan.nextPayment),
          _detailRow('Status', loan.status),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
