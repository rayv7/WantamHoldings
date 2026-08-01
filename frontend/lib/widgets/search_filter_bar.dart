import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF0A4D8C)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search transactions',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_outlined, color: Color(0xFF0A4D8C)),
          ),
        ],
      ),
    );
  }
}
