import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/widgets/banking_scaffold.dart';
import '../domain/profile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return BankingScaffold(
      title: 'Profile',
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
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
      builder: (_) => AppFormDialog(
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
                        Text('Profile', style: theme.textTheme.headlineSmall),
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
                  _ProfileRow('Full Name', '*******'),
                  _ProfileRow('Email', user.email),
                  _ProfileRow('Phone Number', '07*****'),
                  _ProfileRow('National ID', '*******'),
                  _ProfileRow('Address', '*******'),
                ],
              ),
              _ProfileCard(
                title: 'Employment Information',
                icon: Icons.business_center_outlined,
                width: _cardWidth(constraints),
                rows: [
                  _ProfileRow('Department', '*******'),
                  _ProfileRow('Branch', '*******'),
                  _ProfileRow(
                    'Role',
                    user.role.isEmpty ? 'Not Available' : user.role,
                  ),
                  _ProfileRow('Employment Status', '*******'),
                  _ProfileRow('Date Joined', '*******'),
                ],
              ),
              _ProfileCard(
                title: 'Account Information',
                icon: Icons.account_balance_outlined,
                width: _cardWidth(constraints),
                rows: const [
                  _ProfileRow('Account Number', '*******'),
                  _ProfileRow('Account Type', '*******'),
                  _ProfileRow('Currency', 'ksh *******'),
                  _ProfileRow('Branch', '*******'),
                ],
              ),
              _ProfileCard(
                title: 'Security',
                icon: Icons.security_outlined,
                width: _cardWidth(constraints),
                rows: const [
                  _ProfileRow('Password Status', 'Available'),
                  _ProfileRow('Two-Factor Authentication', 'Available'),
                  _ProfileRow('Last Login Date', '__.__.__.____'),
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
