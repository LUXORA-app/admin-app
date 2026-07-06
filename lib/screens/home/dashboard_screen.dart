import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/admin_data_store.dart';
import '../../core/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../widgets/app_background.dart';
import 'landmarks_admin_screen.dart';
import 'users_admin_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.onEditUsers,
    this.onEditLandmarks,
  });

  final VoidCallback? onEditUsers;
  final VoidCallback? onEditLandmarks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return AppBackground(
      child: SafeArea(
        child: Consumer<AdminDataStore>(
          builder: (context, store, _) {
            final bottomInset =
                MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate('dashboard'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.translate('dashboardOverview'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.dashboard_outlined,
                          label: loc.translate('users'),
                          value: '${store.userCount}',
                          color: theme.colorScheme.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.place_outlined,
                          label: loc.translate('landmarks'),
                          value: '${store.landmarkCount}',
                          color: theme.colorScheme.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    loc.translate('recentUsers'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (store.recentUsers.isEmpty)
                    Text(
                      loc.translate('noUsersYet'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    ...store.recentUsers.map(
                      (u) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                            ),
                          ),
                          title: Text(u.name),
                          subtitle: Text(u.email),
                          trailing: u.blocked
                              ? Icon(Icons.block, color: theme.colorScheme.error, size: 20)
                              : null,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    loc.translate('quickActions'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            if (onEditUsers != null) {
                              onEditUsers!();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UsersAdminScreen(),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(loc.translate('editUsers')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            if (onEditLandmarks != null) {
                              onEditLandmarks!();
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LandmarksAdminScreen(),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.edit_location_alt_outlined),
                          label: Text(loc.translate('editLandmarks')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
