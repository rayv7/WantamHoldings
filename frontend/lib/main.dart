import 'package:flutter/material.dart';
import 'core/user_store.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserStore.load();
  runApp(const BankApp());
}
