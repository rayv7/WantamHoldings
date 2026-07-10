import 'package:flutter/material.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 60,
          right: 40,
          top: 70,
          bottom: 60,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),

            const Text(
              "Welcome to\nWantam Holdings",
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
                height: 1.08,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              "Login to access your account",
              style: TextStyle(color: Colors.white70, fontSize: 24),
            ),

            const SizedBox(height: 35),

            const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  "Secure. Reliable. Growth-focused.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}
