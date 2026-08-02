import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer.dart';

class UserStore {
  static String name = '';
  static String email = '';
  static String phone = '';
  static String branch = '';

  static String get firstName => name.split(' ').first;

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
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name') ?? '';
    email = prefs.getString('email') ?? '';
    phone = prefs.getString('phone') ?? '';
    branch = prefs.getString('branch') ?? '';
  }

  static void clear() {
    name = '';
    email = '';
    phone = '';
    branch = '';
  }
}