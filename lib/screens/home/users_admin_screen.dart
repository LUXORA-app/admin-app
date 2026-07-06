import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/admin_data_store.dart';
import '../../core/app_localizations.dart';
import '../../core/app_colors.dart';
import '../../widgets/app_background.dart';

class UsersAdminScreen extends StatefulWidget {
  const UsersAdminScreen({super.key});

  @override
  State<UsersAdminScreen> createState() => _UsersAdminScreenState();
}

class _UsersAdminScreenState extends State<UsersAdminScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminDataStore>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, AdminUser user) async {
    final loc = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('deleteUser')),
        content: Text(
          loc.translateWith('removeUserPermanently', {'name': user.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.translate('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.translate('delete')),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await context.read<AdminDataStore>().deleteUser(user);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void _showAddUserSheet(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.translate('addUser'),
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: loc.translate('name')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: loc.translate('email')),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final email = emailCtrl.text.trim();
                  if (name.isEmpty || email.isEmpty) return;
                  // Backend doesn't expose "create user" admin endpoint; keep UI-only for now.
                  // If needed, we'll add an endpoint in Laravel and wire it here.
                  Navigator.pop(ctx);
                },
                child: Text(loc.translate('add')),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return AppBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    loc.translate('users'),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    onPressed: () => _showAddUserSheet(context),
                    icon: const Icon(Icons.person_add_outlined),
                    tooltip: loc.translate('addUser'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: loc.translate('searchUsersHint'),
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<AdminDataStore>(
                builder: (context, store, _) {
                  if (store.loadingUsers && store.users.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (store.lastError != null && store.users.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          store.lastError!,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  final list = store.searchUsers(_search.text);
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        loc.translate('noUsersMatchSearch'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  final bottomInset =
                      MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final u = list[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?'),
                          ),
                          title: Text(u.name),
                          isThreeLine: u.blocked,
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.email),
                              if (u.blocked)
                                Text(
                                  loc.translate('blocked'),
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (u.blocked)
                                IconButton(
                                  icon: Icon(
                                    Icons.task_alt,
                                    color: theme.colorScheme.primary,
                                  ),
                                  tooltip: loc.translate('unblock'),
                                  onPressed: () async {
                                    try {
                                      await store.setUserBlocked(u, false);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString().replaceFirst('Exception: ', ''),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                )
                              else
                                IconButton(
                                  icon: Icon(
                                    Icons.block,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  tooltip: loc.translate('block'),
                                  onPressed: () async {
                                    try {
                                      await store.setUserBlocked(u, true);
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            e.toString().replaceFirst('Exception: ', ''),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: theme.colorScheme.error,
                                ),
                                tooltip: loc.translate('delete'),
                                onPressed: () => _confirmDelete(context, u),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
