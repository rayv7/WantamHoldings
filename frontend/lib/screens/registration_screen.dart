import 'package:flutter/material.dart';

import '../widgets/left_panel.dart';
import '../widgets/registration_card.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.28)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isMobile = constraints.maxWidth < 900;

                if (isMobile) {
                  return const Center(child: RegistrationCard());
                }

                return const Row(
                  children: [
                    Expanded(flex: 3, child: LeftPanel()),
                    Expanded(flex: 2, child: RegistrationCard()),
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