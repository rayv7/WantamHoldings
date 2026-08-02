import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer.dart';

class UserStore {
  static String name = '';
  static String email = '';
  static String phone = '';
  static String branch = '';
  static String accountNumber = '';
  static String accountType = '';
  static double balance = 0;
  static String accountStatus = '';
  static String openedOn = '';

  static String get firstName => name.split(' ').first;

  static String get formattedBalance {
    final formatted = balance.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return 'KES $formatted';
  }

  static String get maskedAccountNumber {
    if (accountNumber.length < 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }

  static CustomerModel toCustomer() => CustomerModel(
        name: name,
        email: email,
        phone: phone,
        branch: branch,
      );

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('phone', phone);
    await prefs.setString('branch', branch);
    await prefs.setString('accountNumber', accountNumber);
    await prefs.setString('accountType', accountType);
    await prefs.setDouble('balance', balance);
    await prefs.setString('accountStatus', accountStatus);
    await prefs.setString('openedOn', openedOn);
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    phone = prefs.getString('phone') ?? '';
    branch = prefs.getString('branch') ?? '';
    accountNumber = prefs.getString('accountNumber') ?? '';
    accountType = prefs.getString('accountType') ?? '';
    balance = prefs.getDouble('balance') ?? 0;
    accountStatus = prefs.getString('accountStatus') ?? '';
    openedOn = prefs.getString('openedOn') ?? '';
  }

  static void clear() {
    name = '';
    email = '';
    phone = '';
    branch = '';
    accountNumber = '';
    accountType = '';
    balance = 0;
    accountStatus = '';
    openedOn = '';
  }
}