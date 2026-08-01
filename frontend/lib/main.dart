import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/api/api_client.dart';
import 'features/banking/data/banking_repository.dart';
import 'features/profile/domain/profile.dart';

final tokenStoreProvider = Provider((_) => TokenStore());
final apiProvider = Provider((ref) => ApiClient(ref.read(tokenStoreProvider)));
final repositoryProvider = Provider(
  (ref) => BankingRepository(ref.read(apiProvider)),
);
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
final profileProvider = FutureProvider.autoDispose<UserProfile>((ref) async {
  final data = await ref.read(repositoryProvider).profile();
  return UserProfile.fromJson(data);
});

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;
  void toggle() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

enum AuthStatus { loading, signedOut, signedIn }

class AuthState {
  const AuthState(this.status, [this.user]);
  final AuthStatus status;
  final Map<String, dynamic>? user;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(restore);
    return const AuthState(AuthStatus.loading);
  }

  Future<void> restore() async {
    if (await ref.read(tokenStoreProvider).read() == null) {
      state = const AuthState(AuthStatus.signedOut);
      return;
    }
    try {
      state = AuthState(
        AuthStatus.signedIn,
        await ref.read(repositoryProvider).profile(),
      );
    } catch (_) {
      await ref.read(tokenStoreProvider).clear();
      state = const AuthState(AuthStatus.signedOut);
    }
  }

  Future<void> login(String email, String password) async {
    final result = await ref
        .read(repositoryProvider)
        .login(email.trim(), password);
    await ref.read(tokenStoreProvider).write(result['accessToken'] as String);
    state = AuthState(
      AuthStatus.signedIn,
      Map<String, dynamic>.from(result['user'] as Map),
    );
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AuthState(AuthStatus.signedOut);
  }
}

void main() => runApp(const ProviderScope(child: WantamApp()));

class WantamApp extends ConsumerWidget {
  const WantamApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'Wantam Holdings',
    debugShowCheckedModeBanner: false,
    themeMode: ref.watch(themeProvider),
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    routerConfig: _router,
  );
}

ThemeData _theme(Brightness brightness) {
  const blue = Color(0xFF0A3D91);
  const gold = Color(0xFFD5A528);
  final scheme = ColorScheme.fromSeed(
    seedColor: blue,
    brightness: brightness,
  ).copyWith(secondary: gold);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const AuthGate()),
    GoRoute(path: '/auth', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
    GoRoute(path: '/customers', builder: (_, __) => const CustomersPage()),
    GoRoute(path: '/accounts', builder: (_, __) => const AccountsPage()),
    GoRoute(
      path: '/transactions',
      builder: (_, __) => const TransactionsPage(),
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
  ],
);

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    if (state.status == AuthStatus.loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted)
        context.go(
          state.status == AuthStatus.signedIn ? '/dashboard' : '/auth',
        );
    });
    return const Scaffold(body: SizedBox());
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _key = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _registering = false;
  final _role = TextEditingController();
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _role.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (_registering) {
        await ref.read(repositoryProvider).register({
          'email': _email.text.trim(),
          'password': _password.text,
          'roleId': _role.text.trim(),
        });
        if (mounted)
          _notice('Registration successful. Sign in with your new account.');
        setState(() => _registering = false);
      } else {
        await ref
            .read(authProvider.notifier)
            .login(_email.text, _password.text);
        if (mounted) context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) _notice(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notice(String message, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? Theme.of(context).colorScheme.error : null,
        ),
      );
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.account_balance,
                  size: 58,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'WANTAM HOLDINGS',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _registering ? 'Create an account' : 'Secure banking access',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email address'),
                  validator: (v) =>
                      v == null ||
                          !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => v == null || v.length < 8
                      ? 'Use at least 8 characters'
                      : null,
                ),
                if (_registering) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _role,
                    decoration: const InputDecoration(labelText: 'Role ID'),
                    validator: (v) => v == null || v.isEmpty
                        ? 'Role ID is required by the API'
                        : null,
                  ),
                ],
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_registering ? 'Create account' : 'Sign in'),
                  ),
                ),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _registering = !_registering),
                  child: Text(
                    _registering
                        ? 'Already have an account? Sign in'
                        : 'New user? Register',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class BankingScaffold extends ConsumerWidget {
  const BankingScaffold({super.key, required this.title, required this.body});
  final String title;
  final Widget body;
  bool _isStaff(String? role) => role != 'CUSTOMER';
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final staff = _isStaff(user?['role']?.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
            icon: const Icon(Icons.dark_mode_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'profile')
                context.go('/profile');
              else {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/auth');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _index(context, staff),
        onDestinationSelected: (i) => context.go(
          (staff
              ? ['/', '/customers', '/accounts', '/transactions', '/profile']
              : ['/', '/accounts', '/transactions', '/profile'])[i],
        ),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(28, 24, 16, 12),
            child: Text(
              'WANTAM HOLDINGS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: Text('Dashboard'),
          ),
          if (staff)
            const NavigationDrawerDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: Text('Customers'),
            ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: Text('Accounts'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: Text('Transactions'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text('Profile'),
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }

  int _index(BuildContext context, bool staff) {
    final l = GoRouterState.of(context).uri.path;
    if (l == '/customers') return 1;
    if (l == '/accounts') return staff ? 2 : 1;
    if (l == '/transactions') return staff ? 3 : 2;
    if (l == '/profile') return staff ? 4 : 3;
    return 0;
  }
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user ?? {};
    final staff = user['role'] != 'CUSTOMER';
    return BankingScaffold(
      title: 'Dashboard',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Welcome back',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(user['email']?.toString() ?? ''),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _ActionCard(
                icon: Icons.account_balance_wallet,
                title: 'Accounts',
                detail: staff
                    ? 'Search and manage bank accounts'
                    : 'Look up an account balance',
                onTap: () => context.go('/accounts'),
              ),
              _ActionCard(
                icon: Icons.swap_horiz,
                title: 'Transactions',
                detail: staff
                    ? 'Post, reverse and review banking activity'
                    : 'Transfer funds and view statements',
                onTap: () => context.go('/transactions'),
              ),
              if (staff)
                _ActionCard(
                  icon: Icons.people,
                  title: 'Customers',
                  detail: 'Create and manage customer records',
                  onTap: () => context.go('/customers'),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected banking services',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Live data is loaded from the Wantam Holdings API. Account summaries require an account number because the API does not currently provide a customer self-service account listing endpoint.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
  final String title, detail;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    child: Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(detail),
            ],
          ),
        ),
      ),
    ),
  );
}

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
          return _ErrorView(error: snapshot.error!, retry: _load);
        final data = snapshot.data;
        final items = _items(data);
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
            _DataTable(
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
      builder: (_) => _FormDialog(
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
              return const _Info(
                'Enter an account number to retrieve its live details.',
              );
            if (s.connectionState != ConnectionState.done)
              return const Center(child: CircularProgressIndicator());
            if (s.hasError) return _ErrorView(error: s.error!, retry: _load);
            final list = _staff
                ? _items(s.data)
                : [Map<String, dynamic>.from(s.data as Map)];
            return _DataTable(
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
      builder: (_) => _FormDialog(
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
              return const _Info(
                'Statements are loaded directly from the banking API.',
              );
            if (s.connectionState != ConnectionState.done)
              return const Center(child: CircularProgressIndicator());
            if (s.hasError)
              return _ErrorView(error: s.error!, retry: _statement);
            return _StatementView(data: s.data);
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
      builder: (_) => _FormDialog(
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

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return BankingScaffold(
      title: 'Profile',
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          error: error,
          retry: () => ref.invalidate(profileProvider),
        ),
        data: (user) => _ProfileContent(user: user),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.user});
  final UserProfile user;

  void _unavailable(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action is not available from the current API.')),
    );
  }

  Future<void> _editProfile(BuildContext context, WidgetRef ref) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _FormDialog(
        title: 'Edit Profile',
        fields: const ['email'],
        initial: {'email': user.email},
        submit: (data) => ref.read(repositoryProvider).updateProfile(data),
      ),
    );
    if (saved == true) {
      ref.invalidate(profileProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: EdgeInsets.all(constraints.maxWidth < 600 ? 16 : 24),
        children: [
          Card(
            elevation: 2,
            color: theme.colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 20,
                runSpacing: 16,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    child: Text(
                      user.initials,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth < 600 ? double.infinity : 390,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Not Available',
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(user.email, style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ProfileChip(
                              icon: Icons.badge_outlined,
                              label: user.id.isEmpty
                                  ? 'Not Available'
                                  : user.id,
                            ),
                            _ProfileChip(
                              icon: Icons.verified_user_outlined,
                              label: user.role.isEmpty
                                  ? 'Not Available'
                                  : user.role,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _editProfile(context, ref),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _ProfileCard(
                title: 'Personal Information',
                icon: Icons.person_outline,
                width: _cardWidth(constraints),
                rows: [
                  _ProfileRow('Full Name', 'Not Available'),
                  _ProfileRow('Email', user.email),
                  _ProfileRow('Phone Number', 'Not Available'),
                  _ProfileRow('National ID', 'Not Available'),
                  _ProfileRow('Address', 'Not Available'),
                ],
              ),
              _ProfileCard(
                title: 'Employment Information',
                icon: Icons.business_center_outlined,
                width: _cardWidth(constraints),
                rows: [
                  _ProfileRow('Department', 'Not Available'),
                  _ProfileRow('Branch', 'Not Available'),
                  _ProfileRow(
                    'Role',
                    user.role.isEmpty ? 'Not Available' : user.role,
                  ),
                  _ProfileRow('Employment Status', 'Not Available'),
                  _ProfileRow('Date Joined', 'Not Available'),
                ],
              ),
              _ProfileCard(
                title: 'Account Information',
                icon: Icons.account_balance_outlined,
                width: _cardWidth(constraints),
                rows: const [
                  _ProfileRow('Account Number', 'Not Available'),
                  _ProfileRow('Account Type', 'Not Available'),
                  _ProfileRow('Currency', 'Not Available'),
                  _ProfileRow('Branch', 'Not Available'),
                ],
              ),
              _ProfileCard(
                title: 'Security',
                icon: Icons.security_outlined,
                width: _cardWidth(constraints),
                rows: const [
                  _ProfileRow('Password Status', 'Not Available'),
                  _ProfileRow('Two-Factor Authentication', 'Not Available'),
                  _ProfileRow('Last Login Date', 'Not Available'),
                  _ProfileRow('Active Session', 'Authenticated'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  Text('Quick Actions', style: theme.textTheme.titleLarge),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _editProfile(context, ref),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profile'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _unavailable(context, 'Password changes'),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Change Password'),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/auth');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _cardWidth(BoxConstraints constraints) => constraints.maxWidth < 760
      ? constraints.maxWidth
      : (constraints.maxWidth - 40) / 2;
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 18),
    label: Text(label, overflow: TextOverflow.ellipsis),
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.title,
    required this.icon,
    required this.width,
    required this.rows,
  });
  final String title;
  final IconData icon;
  final double width;
  final List<_ProfileRow> rows;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),
            ...rows,
          ],
        ),
      ),
    ),
  );
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _FormDialog extends StatefulWidget {
  const _FormDialog({
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
  State<_FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<_FormDialog> {
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

List<Map<String, dynamic>> _items(dynamic data) {
  if (data is List)
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  if (data is Map) {
    final source = data['data'] ?? data['items'] ?? data['results'];
    if (source is List)
      return source.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  return const [];
}

class _DataTable extends StatelessWidget {
  const _DataTable({
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
    if (items.isEmpty) return const _Info('No records found.');
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

class _StatementView extends StatelessWidget {
  const _StatementView({required this.data});
  final dynamic data;
  @override
  Widget build(BuildContext context) {
    final records = _items(data);
    if (records.isNotEmpty)
      return _DataTable(
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
    return const _Info('No transactions found for this account.');
  }
}

class _Info extends StatelessWidget {
  const _Info(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(18), child: Text(text)),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.retry});
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
