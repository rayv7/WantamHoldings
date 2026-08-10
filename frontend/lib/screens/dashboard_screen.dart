import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/routes.dart';
import '../core/user_store.dart';
import '../core/admin_store.dart';
import '../models/transaction.dart';
import '../widgets/account_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/transaction_tile.dart';
import 'loan_screen.dart';
import 'profile_screen.dart';
import 'transaction_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  Widget _buildScreen() {
    switch (_selectedIndex) {
      case 0:
        return DashboardHomeView(onRefresh: () => setState(() {}));
      case 1:
        return const TransactionHistoryScreen();
      case 2:
        return const LoanScreen();
      case 3:
        return const ProfileScreen();
      default:
        return DashboardHomeView(onRefresh: () => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3EEF1),
      appBar: AppBar(
        title: Text(
          'Welcome Back',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A4D8C),
          ),
        ),
        backgroundColor: const Color(0xFFE3EEF1),
        foregroundColor: const Color(0xFF0A4D8C),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: _buildScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: const Color(0xFFE3EEF1),
        indicatorColor: const Color(0xFF0A4D8C).withValues(alpha: 0.12),
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance),
            label: 'Loans',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardHomeView extends StatefulWidget {
  final VoidCallback onRefresh;

  const DashboardHomeView({super.key, required this.onRefresh});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  Future<void> _navigateAndRefresh(String route) async {
    final result = await Navigator.pushNamed(context, route);
    if (result == true) {
      widget.onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userTxns = AdminStore.transactions
        .where((t) => t.accountNumber == UserStore.accountNumber)
        .take(3)
        .toList();
    final recentTxns = userTxns.map((t) {
      final sign = t.type == 'Deposit' ? '+' : '-';
      return TransactionModel(
        type: t.type,
        merchant: t.customerName,
        date: t.date,
        time: t.time,
        amount: '$sign${t.formattedAmount}',
        status: t.status,
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning, ${UserStore.firstName}',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Routes.pushToAccount(context),
            child: AccountCard(
              balance: UserStore.formattedBalance.replaceAll('KES ', ''),
              accountNumber: UserStore.maskedAccountNumber,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final actions = [
                  (
                    Icons.account_balance_wallet_outlined,
                    'Account',
                    const Color(0xFF0A4D8C),
                    () => Routes.pushToAccount(context),
                  ),
                  (
                    Icons.arrow_downward,
                    'Deposit',
                    const Color(0xFF1F8A5C),
                    () => _navigateAndRefresh(Routes.deposit),
                  ),
                  (
                    Icons.arrow_upward,
                    'Withdraw',
                    const Color(0xFFB5551F),
                    () => _navigateAndRefresh(Routes.withdrawal),
                  ),
                  (
                    Icons.swap_horiz,
                    'Transfer',
                    const Color(0xFF7B61FF),
                    () => _navigateAndRefresh(Routes.transfer),
                  ),
                  (
                    Icons.receipt_long,
                    'History',
                    const Color(0xFF0F766E),
                    () => Routes.pushToTransactions(context),
                  ),
                  (
                    Icons.request_quote_outlined,
                    'Loans',
                    const Color(0xFF7C3AED),
                    () => Routes.pushToLoans(context),
                  ),
                ];

                final action = actions[index];

                return SizedBox(
                  width: 68,
                  child: QuickActionButton(
                    icon: action.$1,
                    label: action.$2,
                    compact: true,
                    color: action.$3,
                    onTap: action.$4,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => Routes.pushToTransactions(context),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...recentTxns
              .map((transaction) => TransactionTile(transaction: transaction))
              .toList(),
        ],
      ),
    );
  }
}