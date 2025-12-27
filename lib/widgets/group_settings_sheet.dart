import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class GroupSettingsSheet extends StatelessWidget {
  final Group group;
  final Map<String, User> members;
  final VoidCallback? onDeleted;
  final VoidCallback? onLeft;

  const GroupSettingsSheet({
    super.key,
    required this.group,
    required this.members,
    this.onDeleted,
    this.onLeft,
  });

  void _copyInviteCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: group.inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite code copied to clipboard')),
    );
  }

  Future<void> _handleLeave(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final auth = context.read<AuthProvider>();
      await context.read<GroupsProvider>().leaveGroup(
            group.id,
            auth.currentUser!.id,
          );
      onLeft?.call();
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
          'Are you sure you want to delete this group? All tasks will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<GroupsProvider>().deleteGroup(group.id);
      onDeleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isOwner = group.creatorId == auth.currentUser?.id;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Group info
                Text(
                  group.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (group.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    group.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mutedText,
                        ),
                  ),
                ],
                const SizedBox(height: 24),

                // Invite code section
                Text(
                  'Invite Code',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.link),
                    title: Text(
                      group.inviteCode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyInviteCode(context),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Share this code with others to invite them to the group',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),

                // Members section
                Text(
                  'Members (${members.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: members.entries.map((entry) {
                      final isCreator = entry.key == group.creatorId;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.gray,
                          child: Text(
                            entry.value.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: AppTheme.black),
                          ),
                        ),
                        title: Text(entry.value.name),
                        subtitle: isCreator
                            ? const Text(
                                'Owner',
                                style: TextStyle(color: AppTheme.mutedText),
                              )
                            : null,
                        trailing: isOwner && !isCreator
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: AppTheme.error,
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Remove Member'),
                                      content: Text(
                                        'Remove ${entry.value.name} from the group?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.error,
                                          ),
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true && context.mounted) {
                                    await context
                                        .read<GroupsProvider>()
                                        .removeMember(group.id, entry.key);
                                  }
                                },
                              )
                            : null,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),

                // Actions
                if (isOwner)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleDelete(context),
                      icon: const Icon(Icons.delete_outline,
                          color: AppTheme.error),
                      label: const Text(
                        'Delete Group',
                        style: TextStyle(color: AppTheme.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLeave(context),
                      icon: const Icon(Icons.exit_to_app,
                          color: AppTheme.error),
                      label: const Text(
                        'Leave Group',
                        style: TextStyle(color: AppTheme.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.error),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
