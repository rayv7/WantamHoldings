import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/banking_scaffold.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});
  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  Future<dynamic>? _future;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = ref.read(repositoryProvider).customers();
    });
  }

  @override
  Widget build(BuildContext context) => BankingScaffold(
    title: 'Customers',
    body: FutureBuilder<dynamic>(
      future: _future,
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return ErrorView(error: snapshot.error!, retry: _load);
        final data = snapshot.data;
        final items = appItems(data);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Text(
                  'Customers',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _customerForm(context),
                  icon: const Icon(Icons.person_add),
                  label: const Text('New customer'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppDataTable(
              items: items,
              columns: const ['Name', 'Phone', 'Status'],
              values: (x) => [
                '${x['firstName'] ?? ''} ${x['lastName'] ?? ''}',
                '${x['phone'] ?? ''}',
                '${x['status'] ?? ''}',
              ],
              onTap: (x) => _customerForm(context, x),
            ),
          ],
        );
      },
    ),
  );
  Future<void> _customerForm(
    BuildContext context, [
    Map<String, dynamic>? current,
  ]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AppFormDialog(
        title: current == null ? 'Create customer' : 'Update customer',
        fields: current == null
            ? const ['firstName', 'lastName', 'nationalId', 'phone', 'userId']
            : const ['firstName', 'lastName', 'phone', 'status'],
        initial: current,
        submit: (data) async {
          if (current == null)
            await ref.read(repositoryProvider).createCustomer(data);
          else
            await ref
                .read(repositoryProvider)
                .updateCustomer('${current['id']}', data);
        },
      ),
    );
    if (result == true) _load();
  }
}
