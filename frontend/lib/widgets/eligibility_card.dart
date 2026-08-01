import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EligibilityCard extends StatelessWidget {
  const EligibilityCard({
    super.key,
    required this.status,
    required this.maxAmount,
    required this.interestRate,
    required this.period,
  });

  final String status;
  final String maxAmount;
  final String interestRate;
  final String period;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0A4D8C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                status,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Eligible Loan Limit',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'KES $maxAmount',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Interest Rate: $interestRate per annum',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          Text(
            'Maximum Period: $period',
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
