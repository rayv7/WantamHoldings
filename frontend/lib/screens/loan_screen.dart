import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/user_store.dart';
import '../models/loan.dart';
import '../widgets/active_loan_card.dart';
import '../widgets/eligibility_card.dart';
import '../widgets/loan_summary_card.dart';

class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final maxLoan = (UserStore.balance * 3).toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    final loanData = LoanModel(
      eligibilityStatus: UserStore.balance > 0 ? 'Eligible' : 'Not Eligible',
      maxLoanAmount: maxLoan,
      interestRate: '13%',
      maxRepaymentPeriod: '36 Months',
      activeLoan: const ActiveLoan(
        type: 'Business Loan',
        originalAmount: 'KES 250,000',
        outstandingBalance: 'KES 142,500',
        monthlyInstallment: 'KES 12,500',
        nextPayment: '30 July 2026',
        status: 'Active',
      ),
      loanHistory: const [
        LoanHistoryItem(
          type: 'Personal Loan',
          amount: 'KES 80,000',
          issuedDate: '10 Jan 2024',
          status: 'Completed',
        ),
        LoanHistoryItem(
          type: 'Student Loan',
          amount: 'KES 40,000',
          issuedDate: '12 Apr 2023',
          status: 'Cleared',
        ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE3EEF1),
      appBar: AppBar(
        title: const Text('Loans'),
        backgroundColor: const Color(0xFFE3EEF1),
        foregroundColor: const Color(0xFF0A4D8C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EligibilityCard(
              status: loanData.eligibilityStatus,
              maxAmount: loanData.maxLoanAmount,
              interestRate: loanData.interestRate,
              period: loanData.maxRepaymentPeriod,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LoanSummaryCard(
                    title: 'Interest Rate',
                    value: loanData.interestRate,
                    subtitle: 'Per annum',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LoanSummaryCard(
                    title: 'Max Period',
                    value: loanData.maxRepaymentPeriod,
                    subtitle: 'Repayment period',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Current Loan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (loanData.activeLoan != null)
              ActiveLoanCard(loan: loanData.activeLoan!)
            else
              const Text('No active loans.'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: const Text('Apply for Loan'),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loan History',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...loanData.loanHistory.map(
              (item) => Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.type,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item.issuedDate,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.amount,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          item.status,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
