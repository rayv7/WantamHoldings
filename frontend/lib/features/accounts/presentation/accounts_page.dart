import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/banking_scaffold.dart';

class AccountsPage extends ConsumerStatefulWidget {
  const AccountsPage({super.key});
  @override
  ConsumerState<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends ConsumerState<AccountsPage> {
  final _search = TextEditingController();
  Future<dynamic>? _future;
  bool get _staff => ref.read(authProvider).user?['role'] != 'CUSTOMER';
  @override
  void initState() {
    super.initState();
    if (_staff) _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() {
    setState(() {
      _future = _staff
          ? ref.read(repositoryProvider).accounts(search: _search.text)
          : ref.read(repositoryProvider).account(_search.text.trim());
    });
  }

  @override
  Widget build(BuildContext context) => BankingScaffold(
    title: 'Accounts',
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Accounts', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  labelText: _staff
                      ? 'Search account or customer'
                      : 'Account number',
                  suffixIcon: const Icon(Icons.search),
                ),
                onSubmitted: (_) => _load(),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(onPressed: _load, child: const Text('Search')),
          ],
        ),
        if (_staff)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _accountForm(context),
                icon: const Icon(Icons.add),
                label: const Text('New account'),
              ),
            ),
          ),
        const SizedBox(height: 16),
        FutureBuilder<dynamic>(
          future: _future,
          builder: (_, s) {
            if (_future == null)
              return const InfoView(
                'Enter an account number to retrieve its live details.',
              );
            if (s.connectionState != ConnectionState.done)
              return const Center(child: CircularProgressIndicator());
            if (s.hasError) return ErrorView(error: s.error!, retry: _load);
            final list = _staff
                ? appItems(s.data)
                : [Map<String, dynamic>.from(s.data as Map)];
            return AppDataTable(
              items: list,
              columns: const ['Number', 'Name', 'Balance', 'Status'],
              values: (x) => [
                '${x['accountNumber'] ?? ''}',
                '${x['accountName'] ?? ''}',
                'KES ${x['balance'] ?? '0'}',
                '${x['status'] ?? ''}',
              ],
              onTap: _staff ? (x) => _accountForm(context, x) : null,
            );
          },
        ),
      ],
    ),
  );
  Future<void> _accountForm(
    BuildContext context, [
    Map<String, dynamic>? current,
  ]) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AppFormDialog(
        title: current == null ? 'Create account' : 'Update account',
        fields: current == null
            ? const ['customerId', 'accountType']
            : const ['accountName', 'status'],
        initial: current,
        submit: (data) async {
          if (current == null)
            await ref.read(repositoryProvider).createAccount(data);
          else
            await ref
                .read(repositoryProvider)
                .updateAccount('${current['id']}', data);
        },
      ),
    );
    if (saved == true) _load();
  }
}
