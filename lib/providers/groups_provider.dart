import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class GroupsProvider extends ChangeNotifier {
  final StorageService _storage;
  List<Group> _groups = [];
  bool _isLoading = false;
  String? _error;

  GroupsProvider(this._storage);

  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserGroups(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = await _storage.getUserGroups(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Group> createGroup(String name, String? description, String creatorId) async {
    final group = Group(
      name: name,
      description: description,
      creatorId: creatorId,
    );
    await _storage.saveGroup(group);
    _groups.add(group);
    notifyListeners();
    return group;
  }

  Future<void> updateGroup(String groupId, {String? name, String? description}) async {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index < 0) return;

    final updatedGroup = _groups[index].copyWith(
      name: name,
      description: description,
    );
    await _storage.saveGroup(updatedGroup);
    _groups[index] = updatedGroup;
    notifyListeners();
  }

  Future<void> deleteGroup(String groupId) async {
    await _storage.deleteGroup(groupId);
    _groups.removeWhere((g) => g.id == groupId);
    notifyListeners();
  }

  Future<Group?> joinGroup(String inviteCode, String userId) async {
    final group = await _storage.getGroupByInviteCode(inviteCode);
    if (group == null) {
      _error = 'Invalid invite code';
      notifyListeners();
      return null;
    }

    if (group.memberIds.contains(userId)) {
      _error = 'You are already a member of this group';
      notifyListeners();
      return group;
    }

    final updatedGroup = group.copyWith(
      memberIds: [...group.memberIds, userId],
    );
    await _storage.saveGroup(updatedGroup);
    
    // Update local list if not already present
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index >= 0) {
      _groups[index] = updatedGroup;
    } else {
      _groups.add(updatedGroup);
    }
    
    notifyListeners();
    return updatedGroup;
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    final group = await _storage.getGroupById(groupId);
    if (group == null) return;

    if (group.creatorId == userId) {
      _error = 'Group owner cannot leave. Delete the group instead.';
      notifyListeners();
      return;
    }

    final updatedGroup = group.copyWith(
      memberIds: group.memberIds.where((id) => id != userId).toList(),
    );
    await _storage.saveGroup(updatedGroup);
    _groups.removeWhere((g) => g.id == groupId);
    notifyListeners();
  }

  Future<void> removeMember(String groupId, String memberId) async {
    final index = _groups.indexWhere((g) => g.id == groupId);
    if (index < 0) return;

    final group = _groups[index];
    final updatedGroup = group.copyWith(
      memberIds: group.memberIds.where((id) => id != memberId).toList(),
    );
    await _storage.saveGroup(updatedGroup);
    _groups[index] = updatedGroup;
    notifyListeners();
  }

  Group? getGroupById(String id) {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
