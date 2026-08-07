import 'package:flutter/material.dart';
import 'core/routes.dart';
import 'core/theme.dart';

class BankApp extends StatelessWidget {
  const BankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wantam Holdings',
      theme: AppTheme.lightTheme,
      initialRoute: Routes.login,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
