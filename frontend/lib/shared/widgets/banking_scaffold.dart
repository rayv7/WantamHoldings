import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_providers.dart';

class BankingScaffold extends ConsumerWidget {
  const BankingScaffold({super.key, required this.title, required this.body});
  final String title;
  final Widget body;
  bool _isStaff(String? role) => role != 'CUSTOMER';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final staff = _isStaff(user?['role']?.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
            icon: const Icon(Icons.dark_mode_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'profile')
                context.go('/profile');
              else {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/auth');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _index(context, staff),
        onDestinationSelected: (i) => context.go(
          (staff
              ? ['/', '/customers', '/accounts', '/transactions', '/profile']
              : ['/', '/accounts', '/transactions', '/profile'])[i],
        ),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 24, 16, 12),
            child: Text(
              'WANTAM HOLDINGS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: Text('Dashboard'),
          ),
          if (staff)
            const NavigationDrawerDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: Text('Customers'),
            ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: Text('Accounts'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: Text('Transactions'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text('Profile'),
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }

  int _index(BuildContext context, bool staff) {
    final l = GoRouterState.of(context).uri.path;
    if (l == '/customers') return 1;
    if (l == '/accounts') return staff ? 2 : 1;
    if (l == '/transactions') return staff ? 3 : 2;
    if (l == '/profile') return staff ? 4 : 3;
    return 0;
  }
}
