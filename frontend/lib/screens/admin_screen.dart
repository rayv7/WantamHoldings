import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/admin_store.dart';
import '../core/routes.dart';
import '../widgets/add_account_dialog.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tabIndex = 0;
  String _searchQuery = '';

  final _messageTitleController = TextEditingController();
  final _messageBodyController = TextEditingController();

  @override
  void dispose() {
    _messageTitleController.dispose();
    _messageBodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3EEF1),
      appBar: AppBar(
        title: Text(
          'Admin Portal',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0A4D8C),
          ),
        ),
        backgroundColor: const Color(0xFFE3EEF1),
        foregroundColor: const Color(0xFF0A4D8C),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Routes.pushToLogin(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatRow(),
          _buildTabBar(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: const Color(0xFF0A4D8C),
      child: Row(
        children: [
          _statCard(
            Icons.people_outline,
            'Total Users',
            '${AdminStore.totalActiveUsers}',
            Colors.white,
          ),
          const SizedBox(width: 10),
          _statCard(
            Icons.account_balance_outlined,
            'Total Deposits',
            'KES ${_format(AdminStore.totalDeposits)}',
            Colors.white,
          ),
          const SizedBox(width: 10),
          _statCard(
            Icons.swap_horiz,
            "Today's TXNs",
            '${AdminStore.todayTransactionCount}',
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _tab('Overview', Icons.dashboard_outlined, 0),
          _tab('Accounts', Icons.people_outline, 1),
          _tab('Transactions', Icons.receipt_long_outlined, 2),
          _tab('Messages', Icons.notifications_outlined, 3),
        ],
      ),
    );
  }

  Widget _tab(String label, IconData icon, int index) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? const Color(0xFF0A4D8C) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? const Color(0xFF0A4D8C) : Colors.grey,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? const Color(0xFF0A4D8C) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildAccountsTab();
      case 2:
        return _buildTransactionsTab();
      case 3:
        return _buildMessagesTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewTab() {
    final recentTxns = AdminStore.transactions.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _actionCard(Icons.person_add, 'Add Account', () => _addAccount()),
              const SizedBox(width: 10),
              _actionCard(Icons.search, 'View Accounts', () =>
                  setState(() => _tabIndex = 1)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Recent Transactions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...recentTxns.map((t) => _txnTile(t)),
        ],
      ),
    );
  }

  Widget _actionCard(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: const Color(0xFF0A4D8C)),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0A4D8C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _txnTile(AdminTransaction t) {
    final icon = t.type == 'Deposit'
        ? Icons.arrow_downward
        : t.type == 'Withdrawal'
            ? Icons.arrow_upward
            : Icons.swap_horiz;
    final color = t.type == 'Deposit'
        ? const Color(0xFF1F8A5C)
        : t.type == 'Withdrawal'
            ? const Color(0xFFB5551F)
            : const Color(0xFF7B61FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.customerName,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                Text('${t.type} · ${t.date} ${t.time}',
                    style: GoogleFonts.poppins(
                        color: Colors.grey[700], fontSize: 12)),
              ],
            ),
          ),
          Text(
            'KES ${_format(t.amount)}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsTab() {
    final filtered = AdminStore.accounts.where((a) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return a.customerName.toLowerCase().contains(q) ||
          a.accountNumber.contains(q) ||
          a.phone.contains(q);
    }).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search accounts...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _addAccount,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A4D8C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final a = filtered[index];
              return _accountRow(a, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _accountRow(AdminAccount a, int storeIndex) {
    final statusColor = a.status == 'Active'
        ? const Color(0xFF1F8A5C)
        : a.status == 'Frozen'
            ? const Color(0xFFB5551F)
            : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                a.customerName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  a.status,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _detailRow('Account', a.accountNumber),
          _detailRow('Phone', a.phone),
          _detailRow('Balance', a.formattedBalance),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionBtn('Edit', Icons.edit_outlined, () => _editAccount(storeIndex)),
              const SizedBox(width: 8),
              _actionBtn(
                a.status == 'Frozen' ? 'Activate' : 'Freeze',
                a.status == 'Frozen' ? Icons.lock_open : Icons.lock_outline,
                () => _toggleFreeze(storeIndex),
              ),
              const SizedBox(width: 8),
              if (a.status != 'Closed')
                _actionBtn('Close', Icons.delete_outline, () => _closeAccount(storeIndex),
                    danger: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13)),
          Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, VoidCallback onTap,
      {bool danger = false}) {
    final color = danger ? const Color(0xFFB5551F) : const Color(0xFF0A4D8C);
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: GoogleFonts.poppins(color: color, fontSize: 12)),
    );
  }

  Widget _buildTransactionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: AdminStore.transactions.length,
      itemBuilder: (context, index) {
        final t = AdminStore.transactions[index];
        return _txnTile(t);
      },
    );
  }

  Widget _buildMessagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send System Message',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _messageTitleController,
                  decoration: InputDecoration(
                    hintText: 'Message Title',
                    filled: true,
                    fillColor: const Color(0xFFF6F8FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _messageBodyController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Message Body',
                    filled: true,
                    fillColor: const Color(0xFFF6F8FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A4D8C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'SEND MESSAGE',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sent Messages',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (AdminStore.messages.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No messages sent yet.',
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
              ),
            )
          else
            ...AdminStore.messages.map((m) => _messageTile(m)),
        ],
      ),
    );
  }

  Widget _messageTile(SystemMessage m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                m.title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              Text(
                m.date,
                style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            m.body,
            style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _addAccount() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const AddAccountDialog(),
    );
    if (result == true) setState(() {});
  }

  void _editAccount(int index) {
    final a = AdminStore.accounts[index];
    final nameCtrl = TextEditingController(text: a.customerName);
    final phoneCtrl = TextEditingController(text: a.phone);
    String type = a.accountType;
    String branch = a.branchName;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Account',
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A4D8C))),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  filled: true,
                  fillColor: const Color(0xFFF6F8FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  filled: true,
                  fillColor: const Color(0xFFF6F8FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(
                  labelText: 'Type',
                  filled: true,
                  fillColor: const Color(0xFFF6F8FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Savings', 'Checking']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) type = v;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: branch,
                decoration: InputDecoration(
                  labelText: 'Branch',
                  filled: true,
                  fillColor: const Color(0xFFF6F8FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Westlands', 'CBD', 'Mombasa', 'Kisumu']
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) branch = v;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      a.customerName = nameCtrl.text.trim();
                      a.phone = phoneCtrl.text.trim();
                      a.accountType = type;
                      a.branchName = branch;
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A4D8C),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleFreeze(int index) {
    setState(() {
      AdminStore.toggleFreeze(index);
      final a = AdminStore.accounts[index];
      AdminStore.addTransaction(AdminTransaction(
        id: 'TXN${DateTime.now().millisecondsSinceEpoch}',
        type: a.status == 'Frozen' ? 'Freeze' : 'Activate',
        accountNumber: a.accountNumber,
        customerName: a.customerName,
        amount: 0,
        date: _today(),
        time: _now(),
      ));
    });
  }

  void _closeAccount(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Close Account'),
        content: Text(
          'Are you sure you want to close ${AdminStore.accounts[index].customerName}\'s account?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                AdminStore.closeAccount(index);
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB5551F),
              foregroundColor: Colors.white,
            ),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final title = _messageTitleController.text.trim();
    final body = _messageBodyController.text.trim();
    if (title.isEmpty || body.isEmpty) return;

    setState(() {
      AdminStore.addMessage(SystemMessage(title: title, body: body));
      _messageTitleController.clear();
      _messageBodyController.clear();
    });
  }

  String _format(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _today() {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _now() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}