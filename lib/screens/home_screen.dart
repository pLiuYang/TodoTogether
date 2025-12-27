import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/create_group_dialog.dart';
import '../widgets/join_group_dialog.dart';
import 'group_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser != null) {
      await context.read<GroupsProvider>().loadUserGroups(auth.currentUser!.id);
    }
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateGroupDialog(
        onCreated: (group) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GroupScreen(groupId: group.id),
            ),
          );
        },
      ),
    );
  }

  void _showJoinGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => JoinGroupDialog(
        onJoined: (group) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GroupScreen(groupId: group.id),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final groupsProvider = context.watch<GroupsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppTheme.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            const Text('TodoTogether'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: AppTheme.gray,
              child: Text(
                auth.currentUser?.name.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                  color: AppTheme.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                auth.signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.currentUser?.name ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                    ),
                    if (auth.currentUser?.email != null)
                      Text(
                        auth.currentUser!.email!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.mutedText,
                        ),
                      ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGroups,
        child: groupsProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : groupsProvider.groups.isEmpty
                ? _buildEmptyState()
                : _buildGroupsList(groupsProvider),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'join',
            onPressed: _showJoinGroupDialog,
            backgroundColor: AppTheme.white,
            foregroundColor: AppTheme.black,
            child: const Icon(Icons.group_add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'create',
            onPressed: _showCreateGroupDialog,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.gray,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.group_outlined,
                color: AppTheme.mutedText,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No groups yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a group to start managing tasks together',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreateGroupDialog,
              icon: const Icon(Icons.add),
              label: const Text('Create your first group'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showJoinGroupDialog,
              icon: const Icon(Icons.group_add),
              label: const Text('Join a group'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsList(GroupsProvider groupsProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupsProvider.groups.length,
      itemBuilder: (context, index) {
        final group = groupsProvider.groups[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.gray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  group.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),
              ),
            ),
            title: Text(
              group.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: group.description != null
                ? Text(
                    group.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    '${group.memberIds.length} member${group.memberIds.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: AppTheme.mutedText),
                  ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GroupScreen(groupId: group.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
