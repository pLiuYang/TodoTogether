import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class TasksProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  // ignore: unused_field
  String? _currentGroupId;
  String? _filterAssigneeId;
  bool _showCompleted = false;

  TasksProvider(this._storage);

  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filterAssigneeId => _filterAssigneeId;
  bool get showCompleted => _showCompleted;

  List<Task> get _filteredTasks {
    var filtered = _tasks.toList();
    
    // Filter by completion status
    if (!_showCompleted) {
      filtered = filtered.where((t) => t.status == TaskStatus.todo).toList();
    }
    
    // Filter by assignee
    if (_filterAssigneeId != null) {
      filtered = filtered.where((t) => t.assigneeId == _filterAssigneeId).toList();
    }
    
    return filtered;
  }

  // Group tasks by reminder time
  Map<String, List<Task>> get groupedTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    // dayAfterTomorrow could be used for future date ranges

    final Map<String, List<Task>> grouped = {
      'Today': [],
      'Tomorrow': [],
      'Upcoming': [],
      'No Date': [],
    };

    for (final task in _filteredTasks) {
      if (task.reminderTime == null) {
        grouped['No Date']!.add(task);
      } else {
        final reminderDate = DateTime(
          task.reminderTime!.year,
          task.reminderTime!.month,
          task.reminderTime!.day,
        );
        
        if (reminderDate.isBefore(today) || reminderDate.isAtSameMomentAs(today)) {
          grouped['Today']!.add(task);
        } else if (reminderDate.isBefore(tomorrow) || reminderDate.isAtSameMomentAs(tomorrow)) {
          grouped['Tomorrow']!.add(task);
        } else {
          grouped['Upcoming']!.add(task);
        }
      }
    }

    // Sort tasks within each group by reminder time
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) {
        if (a.reminderTime == null && b.reminderTime == null) {
          return a.createdAt.compareTo(b.createdAt);
        }
        if (a.reminderTime == null) return 1;
        if (b.reminderTime == null) return -1;
        return a.reminderTime!.compareTo(b.reminderTime!);
      });
    }

    return grouped;
  }

  Future<void> loadGroupTasks(String groupId) async {
    _isLoading = true;
    _error = null;
    _currentGroupId = groupId;
    notifyListeners();

    try {
      _tasks = await _storage.getGroupTasks(groupId, includeCompleted: true);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Task> createTask({
    required String title,
    String? description,
    required String creatorId,
    String? assigneeId,
    required String groupId,
    DateTime? reminderTime,
  }) async {
    final task = Task(
      title: title,
      description: description,
      creatorId: creatorId,
      assigneeId: assigneeId,
      groupId: groupId,
      reminderTime: reminderTime,
    );
    await _storage.saveTask(task);
    _tasks.add(task);
    notifyListeners();
    return task;
  }

  Future<void> updateTask(
    String taskId, {
    String? title,
    String? description,
    String? assigneeId,
    DateTime? reminderTime,
    bool clearAssignee = false,
    bool clearReminder = false,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index < 0) return;

    final updatedTask = _tasks[index].copyWith(
      title: title,
      description: description,
      assigneeId: assigneeId,
      reminderTime: reminderTime,
      clearAssignee: clearAssignee,
      clearReminder: clearReminder,
    );
    await _storage.saveTask(updatedTask);
    _tasks[index] = updatedTask;
    notifyListeners();
  }

  Future<void> toggleTaskStatus(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index < 0) return;

    final task = _tasks[index];
    final newStatus = task.status == TaskStatus.todo ? TaskStatus.done : TaskStatus.todo;
    final updatedTask = task.copyWith(status: newStatus);
    await _storage.saveTask(updatedTask);
    _tasks[index] = updatedTask;
    notifyListeners();
  }

  Future<void> deleteTask(String taskId) async {
    await _storage.deleteTask(taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  void setFilterAssignee(String? assigneeId) {
    _filterAssigneeId = assigneeId;
    notifyListeners();
  }

  void setShowCompleted(bool show) {
    _showCompleted = show;
    notifyListeners();
  }

  void clearFilters() {
    _filterAssigneeId = null;
    _showCompleted = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
