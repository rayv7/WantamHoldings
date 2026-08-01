import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/banking_scaffold.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user ?? {};
    final staff = user['role'] != 'CUSTOMER';
    return BankingScaffold(
      title: 'Dashboard',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Welcome back',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(user['email']?.toString() ?? ''),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _ActionCard(
                icon: Icons.account_balance_wallet,
                title: 'Accounts',
                detail: staff
                    ? 'Search and manage bank accounts'
                    : 'Look up an account balance',
                onTap: () => context.go('/accounts'),
              ),
              _ActionCard(
                icon: Icons.swap_horiz,
                title: 'Transactions',
                detail: staff
                    ? 'Post, reverse and review banking activity'
                    : 'Transfer funds and view statements',
                onTap: () => context.go('/transactions'),
              ),
              if (staff)
                _ActionCard(
                  icon: Icons.people,
                  title: 'Customers',
                  detail: 'Create and manage customer records',
                  onTap: () => context.go('/customers'),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected banking services',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Live data is loaded from the Wantam Holdings API. Account summaries require an account number because the API does not currently provide a customer self-service account listing endpoint.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
  final String title, detail;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(detail),
            ],
          ),
        ),
      ),
    ),
  );
}
