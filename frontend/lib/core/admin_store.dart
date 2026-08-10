import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAccount {
  String accountNumber;
  String customerName;
  String phone;
  String email;
  String pin;
  String accountType;
  String branchName;
  double balance;
  String status;
  String openedOn;

  AdminAccount({
    this.accountNumber = '',
    required this.customerName,
    required this.phone,
    this.email = '',
    this.pin = '1234',
    this.accountType = 'Savings',
    this.branchName = 'Westlands',
    this.balance = 0,
    this.status = 'Active',
    String? openedOn,
  }) : openedOn = openedOn ?? _today();

  static String _today() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String get formattedBalance => 'KES ${_format(balance)}';

  static String _format(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}

class AdminTransaction {
  final String id;
  final String type;
  final String accountNumber;
  final String customerName;
  final double amount;
  final String date;
  final String time;
  final String status;

  AdminTransaction({
    required this.id,
    required this.type,
    required this.accountNumber,
    required this.customerName,
    required this.amount,
    required this.date,
    required this.time,
    this.status = 'Completed',
  });

  String get formattedAmount {
    final formatted = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return 'KES $formatted';
  }
}

class SystemMessage {
  String title;
  String body;
  final String date;

  SystemMessage({
    required this.title,
    required this.body,
    String? date,
  }) : date = date ?? _today();

  static String _today() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class AdminStore {
  static final List<AdminAccount> accounts = [
    AdminAccount(
      accountNumber: '0123456789',
      customerName: 'Brian Ochieng',
      phone: '+254 712 345 678',
      email: 'brian@wantam.co',
      pin: '1234',
      accountType: 'Savings',
      branchName: 'Westlands',
      balance: 240000,
      openedOn: '14 Jan 2022',
    ),
    AdminAccount(
      accountNumber: '0987654321',
      customerName: 'Ann Wanjiru',
      phone: '+254 723 456 789',
      email: 'ann@wantam.co',
      pin: '5678',
      accountType: 'Checking',
      branchName: 'CBD',
      balance: 520000,
      openedOn: '03 Mar 2021',
    ),
    AdminAccount(
      accountNumber: '0555666777',
      customerName: 'Peter Kamau',
      phone: '+254 734 567 890',
      email: 'peter@wantam.co',
      pin: '9012',
      accountType: 'Savings',
      branchName: 'Mombasa',
      balance: 85000,
      openedOn: '22 Aug 2023',
    ),
    AdminAccount(
      accountNumber: '0444333222',
      customerName: 'Mary Akinyi',
      phone: '+254 745 678 901',
      email: 'mary@wantam.co',
      pin: '3456',
      accountType: 'Checking',
      branchName: 'Kisumu',
      balance: 1200000,
      openedOn: '10 Nov 2020',
    ),
    AdminAccount(
      accountNumber: '0777888999',
      customerName: 'James Mwangi',
      phone: '+254 756 789 012',
      email: 'james@wantam.co',
      pin: '7890',
      accountType: 'Savings',
      branchName: 'Westlands',
      balance: 15000,
      status: 'Frozen',
      openedOn: '05 Jun 2024',
    ),
  ];

  static final List<AdminTransaction> transactions = [
    AdminTransaction(
      id: 'TXN001',
      type: 'Deposit',
      accountNumber: '0123456789',
      customerName: 'Brian Ochieng',
      amount: 50000,
      date: '30 Jul 2026',
      time: '09:15',
    ),
    AdminTransaction(
      id: 'TXN002',
      type: 'Withdrawal',
      accountNumber: '0987654321',
      customerName: 'Ann Wanjiru',
      amount: 10000,
      date: '30 Jul 2026',
      time: '10:30',
    ),
    AdminTransaction(
      id: 'TXN003',
      type: 'Transfer',
      accountNumber: '0555666777',
      customerName: 'Peter Kamau',
      amount: 25000,
      date: '29 Jul 2026',
      time: '14:00',
    ),
    AdminTransaction(
      id: 'TXN004',
      type: 'Deposit',
      accountNumber: '0444333222',
      customerName: 'Mary Akinyi',
      amount: 200000,
      date: '29 Jul 2026',
      time: '08:45',
    ),
    AdminTransaction(
      id: 'TXN005',
      type: 'Withdrawal',
      accountNumber: '0123456789',
      customerName: 'Brian Ochieng',
      amount: 7500,
      date: '28 Jul 2026',
      time: '18:30',
    ),
  ];

  static final List<SystemMessage> messages = [];

  static int _accountCounter = 100;

  static double get totalDeposits {
    double total = 0;
    for (final a in accounts) {
      if (a.status == 'Active') total += a.balance;
    }
    return total;
  }

  static int get totalActiveUsers {
    int count = 0;
    for (final a in accounts) {
      if (a.status == 'Active') count++;
    }
    return count;
  }

  static int get todayTransactionCount {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    final today = '${now.day} ${months[now.month - 1]} ${now.year}';
    int count = 0;
    for (final t in transactions) {
      if (t.date == today) count++;
    }
    return count;
  }

  static void addAccount(AdminAccount account) {
    _accountCounter++;
    account.accountNumber = _accountCounter.toString().padLeft(10, '0');
    accounts.add(account);
  }

  static void toggleFreeze(int index) {
    if (index >= 0 && index < accounts.length) {
      accounts[index].status =
          accounts[index].status == 'Frozen' ? 'Active' : 'Frozen';
    }
  }

  static void closeAccount(int index) {
    if (index >= 0 && index < accounts.length) {
      accounts[index].status = 'Closed';
    }
  }

  static void addTransaction(AdminTransaction t) {
    transactions.insert(0, t);
  }

  static void addMessage(SystemMessage m) {
    messages.insert(0, m);
  }

  static AdminAccount? getAccountByPhone(String phone) {
    for (final a in accounts) {
      if (a.phone == phone) return a;
    }
    return null;
  }

  static AdminAccount? getAccountByUsername(String username) {
    for (final a in accounts) {
      if (a.phone == username || a.email == username) return a;
    }
    return null;
  }

  static AdminAccount? getAccountByNumber(String accountNumber) {
    for (final a in accounts) {
      if (a.accountNumber == accountNumber) return a;
    }
    return null;
  }

  static bool isAccountFrozen(String accountNumber) {
    final account = getAccountByNumber(accountNumber);
    return account?.status == 'Frozen';
  }

  static final Map<String, String> _passwords = {};

  static bool hasPassword(String phone) => _passwords.containsKey(phone);

  static void setPassword(String phone, String password) {
    _passwords[phone] = password;
  }

  static bool verifyPassword(String phone, String password) {
    return _passwords[phone] == password;
  }

  static Future<void> savePasswords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_passwords', jsonEncode(_passwords));
  }

  static Future<void> loadPasswords() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('admin_passwords');
    if (stored != null && stored.isNotEmpty) {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      _passwords.clear();
      for (final entry in decoded.entries) {
        _passwords[entry.key] = entry.value.toString();
      }
    }
  }
}