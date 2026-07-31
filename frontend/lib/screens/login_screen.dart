import 'package:flutter/material.dart';

import '../widgets/left_panel.dart';
import '../widgets/login_card.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.28)),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isMobile = constraints.maxWidth < 900;

                if (isMobile) {
                  return const Center(child: LoginCard());
                }

                return const Row(
                  children: [
                    Expanded(flex: 3, child: LeftPanel()),

                    Expanded(flex: 2, child: LoginCard()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
