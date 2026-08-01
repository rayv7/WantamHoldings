import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/accounts/presentation/accounts_page.dart';
import '../features/auth/presentation/auth_pages.dart';
import '../features/customers/presentation/customers_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/transactions/presentation/transactions_page.dart';
import '../shared/providers/app_providers.dart';

class WantamApp extends ConsumerWidget {
  const WantamApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Wantam Holdings',
    debugShowCheckedModeBanner: false,
    themeMode: ref.watch(themeProvider),
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    routerConfig: _router,
  );
}

ThemeData _theme(Brightness brightness) {
  const blue = Color(0xFF0A3D91);
  const gold = Color(0xFFD5A528);
  final scheme = ColorScheme.fromSeed(
    seedColor: blue,
    brightness: brightness,
  ).copyWith(secondary: gold);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const AuthGate()),
    GoRoute(path: '/auth', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
    GoRoute(path: '/customers', builder: (_, __) => const CustomersPage()),
    GoRoute(path: '/accounts', builder: (_, __) => const AccountsPage()),
    GoRoute(
      path: '/transactions',
      builder: (_, __) => const TransactionsPage(),
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
  ],
);
