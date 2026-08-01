import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../widgets/account_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/transaction_tile.dart';
import 'account_screen.dart';
import 'deposit_screen.dart';
import 'loan_screen.dart';
import 'profile_screen.dart';
import 'transaction_history_screen.dart';
import 'transfer_screen.dart';
import 'withdrawal_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardHomeView(),
    TransactionHistoryScreen(),
    LoanScreen(),
    ProfileScreen(),
  ];

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
      body: _screens[_selectedIndex],
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

class DashboardHomeView extends StatelessWidget {
  const DashboardHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      const TransactionModel(
        type: 'Transfer',
        merchant: 'Nancy Wanjiru',
        date: '30 Jul',
        time: '09:15',
        amount: '-KES 7,500',
        status: 'Completed',
      ),
      const TransactionModel(
        type: 'Deposit',
        merchant: 'Salary',
        date: '29 Jul',
        time: '08:00',
        amount: '+KES 55,000',
        status: 'Completed',
      ),
      const TransactionModel(
        type: 'Withdrawal',
        merchant: 'ATM',
        date: '28 Jul',
        time: '18:30',
        amount: '-KES 3,000',
        status: 'Completed',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning, Brian',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your finances are looking healthy today.',
            style: GoogleFonts.poppins(color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountScreen()),
            ),
            child: const AccountCard(
              balance: '240,000',
              accountNumber: '****6789',
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
                    MaterialPageRoute(builder: (_) => const AccountScreen()),
                  ),
                  (
                    Icons.arrow_downward,
                    'Deposit',
                    const Color(0xFF1F8A5C),
                    MaterialPageRoute(builder: (_) => const DepositScreen()),
                  ),
                  (
                    Icons.arrow_upward,
                    'Withdraw',
                    const Color(0xFFB5551F),
                    MaterialPageRoute(builder: (_) => const WithdrawalScreen()),
                  ),
                  (
                    Icons.swap_horiz,
                    'Transfer',
                    const Color(0xFF7B61FF),
                    MaterialPageRoute(builder: (_) => const TransferScreen()),
                  ),
                  (
                    Icons.receipt_long,
                    'History',
                    const Color(0xFF0F766E),
                    MaterialPageRoute(
                      builder: (_) => const TransactionHistoryScreen(),
                    ),
                  ),
                  (
                    Icons.request_quote_outlined,
                    'Loans',
                    const Color(0xFF7C3AED),
                    MaterialPageRoute(builder: (_) => const LoanScreen()),
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
                    onTap: () => Navigator.push(context, action.$4),
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TransactionHistoryScreen(),
                  ),
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...transactions
              .map((transaction) => TransactionTile(transaction: transaction))
              .toList(),
        ],
      ),
    );
  }
}
