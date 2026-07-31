import 'package:flutter/material.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(
        left: width > 1400 ? 90 : 60,
        right: 40,
        top: 70,
        bottom: 60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),

          Text(
            "Welcome to\nWantam Holdings",
            style: TextStyle(
              color: Colors.white,
              fontSize: width > 1400 ? 56 : 50,
              fontWeight: FontWeight.bold,
              height: 1.08,
            ),
          ),

          const SizedBox(height: 22),

          Text(
            "Login to access your account",
            style: TextStyle(
              color: Colors.white70,
              fontSize: width > 1400 ? 26 : 24,
            ),
          ),

          const SizedBox(height: 35),

          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.white, size: 22),

              SizedBox(width: 10),

              Expanded(
                child: Text(
                  "Secure. Reliable. Growth-focused.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 35),
        ],
      ),
    );
  }
}
