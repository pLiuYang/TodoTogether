import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/edit_task_dialog.dart';
import '../widgets/group_settings_sheet.dart';

class GroupScreen extends StatefulWidget {
  final String groupId;

  const GroupScreen({super.key, required this.groupId});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  Group? _group;
  Map<String, User> _members = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final groupsProvider = context.read<GroupsProvider>();
    final tasksProvider = context.read<TasksProvider>();
    final storage = context.read<StorageService>();

    _group = groupsProvider.getGroupById(widget.groupId);
    if (_group == null) {
      _group = await storage.getGroupById(widget.groupId);
    }

    if (_group != null) {
      // Load members
      final members = <String, User>{};
      for (final memberId in _group!.memberIds) {
        final user = await storage.getUserById(memberId);
        if (user != null) {
          members[memberId] = user;
        }
      }
      setState(() => _members = members);

      // Load tasks
      await tasksProvider.loadGroupTasks(widget.groupId);
    }
  }

  void _showCreateTaskDialog() {
    if (_group == null) return;
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(
        group: _group!,
        members: _members,
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    if (_group == null) return;
    showDialog(
      context: context,
      builder: (context) => EditTaskDialog(
        task: task,
        group: _group!,
        members: _members,
      ),
    );
  }

  void _showGroupSettings() {
    if (_group == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GroupSettingsSheet(
        group: _group!,
        members: _members,
        onDeleted: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        onLeft: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showFilterMenu() {
    final tasksProvider = context.read<TasksProvider>();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.filter_list),
              title: const Text('Filter by Assignee'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('All Tasks'),
              selected: tasksProvider.filterAssigneeId == null,
              onTap: () {
                tasksProvider.setFilterAssignee(null);
                Navigator.pop(context);
              },
            ),
            ..._members.entries.map((entry) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.gray,
                    child: Text(
                      entry.value.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: AppTheme.black),
                    ),
                  ),
                  title: Text(entry.value.name),
                  selected: tasksProvider.filterAssigneeId == entry.key,
                  onTap: () {
                    tasksProvider.setFilterAssignee(entry.key);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();
    final auth = context.watch<AuthProvider>();

    if (_group == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_group!.name),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: tasksProvider.filterAssigneeId != null,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterMenu,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showGroupSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: tasksProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : tasksProvider.tasks.isEmpty
                ? _buildEmptyState()
                : _buildTasksList(tasksProvider, auth),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
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
                Icons.task_outlined,
                color: AppTheme.mutedText,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No tasks yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first task to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showCreateTaskDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(TasksProvider tasksProvider, AuthProvider auth) {
    final groupedTasks = tasksProvider.groupedTasks;
    final sections = ['Today', 'Tomorrow', 'Upcoming', 'No Date'];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        final tasks = groupedTasks[section] ?? [];

        if (tasks.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                section,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.mutedText,
                    ),
              ),
            ),
            ...tasks.map((task) => _buildTaskCard(task, tasksProvider)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildTaskCard(Task task, TasksProvider tasksProvider) {
    final assignee = task.assigneeId != null ? _members[task.assigneeId] : null;
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditTaskDialog(task),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.status == TaskStatus.done,
                  onChanged: (_) => tasksProvider.toggleTaskStatus(task.id),
                  shape: const CircleBorder(),
                ),
              ),
              const SizedBox(width: 8),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: task.status == TaskStatus.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == TaskStatus.done
                            ? AppTheme.mutedText
                            : AppTheme.black,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (task.reminderTime != null)
                          _buildChip(
                            Icons.access_time,
                            dateFormat.format(task.reminderTime!),
                          ),
                        if (assignee != null)
                          _buildChip(
                            Icons.person_outline,
                            assignee.name,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.gray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.mutedText),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
