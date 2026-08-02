import 'package:flutter/material.dart';
import 'core/admin_store.dart';
import 'core/user_store.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserStore.load();
  await AdminStore.loadPasswords();
  runApp(const BankApp());
}
