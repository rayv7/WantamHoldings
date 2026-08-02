import 'package:flutter/material.dart';

import '../screens/account_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/deposit_screen.dart';
import '../screens/loan_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/registration_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../screens/transfer_screen.dart';
import '../screens/withdrawal_screen.dart';

/// Central routing configuration for the app.
/// Uses named routes with [onGenerateRoute] so all navigation
/// goes through a single switch statement instead of inline
/// [MaterialPageRoute] constructors.
class Routes {
  Routes._();

  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String account = '/account';
  static const String deposit = '/deposit';
  static const String withdrawal = '/withdrawal';
  static const String transfer = '/transfer';
  static const String transactions = '/transactions';
  static const String loans = '/loans';
  static const String profile = '/profile';
  static const String registration = '/registration';

  // Route generator – wired into [MaterialApp.onGenerateRoute]

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case account:
        return MaterialPageRoute(builder: (_) => const AccountScreen());
      case deposit:
        return MaterialPageRoute(builder: (_) => const DepositScreen());
      case withdrawal:
        return MaterialPageRoute(builder: (_) => const WithdrawalScreen());
      case transfer:
        return MaterialPageRoute(builder: (_) => const TransferScreen());
      case transactions:
        return MaterialPageRoute(
          builder: (_) => const TransactionHistoryScreen(),
        );
      case loans:
        return MaterialPageRoute(builder: (_) => const LoanScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case registration:
        return MaterialPageRoute(
          builder: (_) => const RegistrationScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }

  /// Replaces the entire stack with the Dashboard (used after login).
  static void pushToDashboard(BuildContext context) {
    Navigator.pushReplacementNamed(context, dashboard);
  }

  static void pushToAccount(BuildContext context) {
    Navigator.pushNamed(context, account);
  }

  static void pushToDeposit(BuildContext context) {
    Navigator.pushNamed(context, deposit);
  }

  static void pushToWithdrawal(BuildContext context) {
    Navigator.pushNamed(context, withdrawal);
  }

  static void pushToTransfer(BuildContext context) {
    Navigator.pushNamed(context, transfer);
  }

  static void pushToTransactions(BuildContext context) {
    Navigator.pushNamed(context, transactions);
  }

  static void pushToLoans(BuildContext context) {
    Navigator.pushNamed(context, loans);
  }

  static void pushToRegistration(BuildContext context) {
    Navigator.pushNamed(context, registration);
  }
}
