import 'package:flutter/material.dart';

class AppFormDialog extends StatefulWidget {
  const AppFormDialog({
    super.key,
    required this.title,
    required this.fields,
    required this.submit,
    this.initial,
  });
  final String title;
  final List<String> fields;
  final Map<String, dynamic>? initial;
  final Future<dynamic> Function(Map<String, String>) submit;
  @override
  State<AppFormDialog> createState() => AppFormDialogState();
}

class AppFormDialogState extends State<AppFormDialog> {
  final _key = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in widget.fields)
        f: TextEditingController(text: widget.initial?[f]?.toString() ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await widget.submit({
        for (final e in _controllers.entries)
          if (e.value.text.trim().isNotEmpty) e.key: e.value.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Saved successfully.')));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SizedBox(
      width: 440,
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final f in widget.fields)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _controllers[f],
                    keyboardType: f == 'amount'
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.text,
                    decoration: InputDecoration(labelText: _label(f)),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? '${_label(f)} is required'
                        : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _busy ? null : _submit,
        child: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save'),
      ),
    ],
  );
  String _label(String field) => field
      .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}')
      .trim()
      .replaceFirstMapped(RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());
}

List<Map<String, dynamic>> appItems(dynamic data) {
  if (data is List)
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  if (data is Map) {
    final source = data['data'] ?? data['items'] ?? data['results'];
    if (source is List)
      return source.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  return const [];
}

class AppDataTable extends StatelessWidget {
  const AppDataTable({
    super.key,
    required this.items,
    required this.columns,
    required this.values,
    this.onTap,
  });
  final List<Map<String, dynamic>> items;
  final List<String> columns;
  final List<String> Function(Map<String, dynamic>) values;
  final void Function(Map<String, dynamic>)? onTap;
  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const InfoView('No records found.');
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [for (final c in columns) DataColumn(label: Text(c))],
          rows: [
            for (final item in items)
              DataRow(
                onSelectChanged: onTap == null ? null : (_) => onTap!(item),
                cells: [for (final v in values(item)) DataCell(Text(v))],
              ),
          ],
        ),
      ),
    );
  }
}

class StatementView extends StatelessWidget {
  const StatementView({super.key, required this.data});
  final dynamic data;
  @override
  Widget build(BuildContext context) {
    final records = appItems(data);
    if (records.isNotEmpty)
      return AppDataTable(
        items: records,
        columns: const ['Reference', 'Type', 'Amount', 'Date'],
        values: (x) => [
          '${x['reference'] ?? ''}',
          '${x['type'] ?? ''}',
          'KES ${x['amount'] ?? ''}',
          '${x['createdAt'] ?? ''}',
        ],
      );
    if (data is Map)
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SelectableText(data.toString()),
        ),
      );
    return const InfoView('No transactions found for this account.');
  }
}

class InfoView extends StatelessWidget {
  const InfoView(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(18), child: Text(text)),
  );
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, required this.retry});
  final Object error;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(error.toString(), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: retry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}
