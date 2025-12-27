import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _usersKey = 'users';
  static const String _groupsKey = 'groups';
  static const String _tasksKey = 'tasks';
  static const String _currentUserKey = 'currentUser';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User methods
  Future<User?> getCurrentUser() async {
    final json = _prefs.getString(_currentUserKey);
    if (json == null) return null;
    return User.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> setCurrentUser(User? user) async {
    if (user == null) {
      await _prefs.remove(_currentUserKey);
    } else {
      await _prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    }
  }

  Future<List<User>> getUsers() async {
    final json = _prefs.getString(_usersKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveUser(User user) async {
    final users = await getUsers();
    final index = users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      users[index] = user;
    } else {
      users.add(user);
    }
    await _prefs.setString(
      _usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  Future<User?> getUserById(String id) async {
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  // Group methods
  Future<List<Group>> getGroups() async {
    final json = _prefs.getString(_groupsKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Group.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveGroup(Group group) async {
    final groups = await getGroups();
    final index = groups.indexWhere((g) => g.id == group.id);
    if (index >= 0) {
      groups[index] = group;
    } else {
      groups.add(group);
    }
    await _prefs.setString(
      _groupsKey,
      jsonEncode(groups.map((g) => g.toJson()).toList()),
    );
  }

  Future<void> deleteGroup(String groupId) async {
    final groups = await getGroups();
    groups.removeWhere((g) => g.id == groupId);
    await _prefs.setString(
      _groupsKey,
      jsonEncode(groups.map((g) => g.toJson()).toList()),
    );
    
    // Also delete all tasks in the group
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.groupId == groupId);
    await _prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  Future<Group?> getGroupById(String id) async {
    final groups = await getGroups();
    try {
      return groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Group?> getGroupByInviteCode(String code) async {
    final groups = await getGroups();
    try {
      return groups.firstWhere(
        (g) => g.inviteCode.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<Group>> getUserGroups(String userId) async {
    final groups = await getGroups();
    return groups.where((g) => g.memberIds.contains(userId)).toList();
  }

  // Task methods
  Future<List<Task>> getTasks() async {
    final json = _prefs.getString(_tasksKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveTask(Task task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    await _prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await _prefs.setString(
      _tasksKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  Future<List<Task>> getGroupTasks(String groupId, {bool includeCompleted = false}) async {
    final tasks = await getTasks();
    return tasks.where((t) {
      if (t.groupId != groupId) return false;
      if (!includeCompleted && t.status == TaskStatus.done) return false;
      return true;
    }).toList();
  }

  Future<Task?> getTaskById(String id) async {
    final tasks = await getTasks();
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}
