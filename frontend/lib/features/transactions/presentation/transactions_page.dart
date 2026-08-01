import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/banking_scaffold.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});
  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final _number = TextEditingController();
  Future<dynamic>? _future;
  bool get _staff => ref.read(authProvider).user?['role'] != 'CUSTOMER';
  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  void _statement() {
    setState(() {
      _future = ref.read(repositoryProvider).statement(_number.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) => BankingScaffold(
    title: 'Transactions',
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Transactions', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ActionButton(
              label: 'Transfer',
              icon: Icons.swap_horiz,
              onTap: () => _form(context, 'transfer'),
            ),
            if (_staff) ...[
              _ActionButton(
                label: 'Deposit',
                icon: Icons.add_card,
                onTap: () => _form(context, 'deposit'),
              ),
              _ActionButton(
                label: 'Withdraw',
                icon: Icons.money_off,
                onTap: () => _form(context, 'withdraw'),
              ),
              _ActionButton(
                label: 'Reverse',
                icon: Icons.undo,
                onTap: () => _form(context, 'reverse'),
              ),
              _ActionButton(
                label: 'Interest',
                icon: Icons.percent,
                onTap: () => _form(context, 'interest'),
              ),
              _ActionButton(
                label: 'Charge',
                icon: Icons.receipt,
                onTap: () => _form(context, 'charge'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Account statement',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _number,
                decoration: const InputDecoration(labelText: 'Account number'),
                onSubmitted: (_) => _statement(),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(onPressed: _statement, child: const Text('Load')),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<dynamic>(
          future: _future,
          builder: (_, s) {
            if (_future == null)
              return const InfoView(
                'Statements are loaded directly from the banking API.',
              );
            if (s.connectionState != ConnectionState.done)
              return const Center(child: CircularProgressIndicator());
            if (s.hasError)
              return ErrorView(error: s.error!, retry: _statement);
            return StatementView(data: s.data);
          },
        ),
      ],
    ),
  );
  Future<void> _form(BuildContext context, String type) async {
    final fields = switch (type) {
      'transfer' => const [
        'senderAccountNumber',
        'receiverAccountNumber',
        'amount',
        'description',
      ],
      'reverse' => const ['reference'],
      'interest' => const ['accountNumber', 'amount'],
      'charge' => const ['accountNumber', 'amount', 'description'],
      _ => const ['accountNumber', 'amount', 'description'],
    };
    await showDialog<bool>(
      context: context,
      builder: (_) => AppFormDialog(
        title: '${type[0].toUpperCase()}${type.substring(1)} transaction',
        fields: fields,
        submit: (data) => ref.read(repositoryProvider).transaction(type, data),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon),
    label: Text(label),
  );
}
