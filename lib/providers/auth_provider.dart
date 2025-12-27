import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storage;
  User? _currentUser;
  bool _isLoading = true;

  AuthProvider(this._storage);

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    _currentUser = await _storage.getCurrentUser();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUp(String name, String? email) async {
    final user = User(name: name, email: email);
    await _storage.saveUser(user);
    await _storage.setCurrentUser(user);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> signIn(String name) async {
    // For simplicity, we'll create/find user by name
    final users = await _storage.getUsers();
    User? user;
    try {
      user = users.firstWhere((u) => u.name.toLowerCase() == name.toLowerCase());
    } catch (_) {
      // Create new user if not found
      user = User(name: name);
      await _storage.saveUser(user);
    }
    
    await _storage.setCurrentUser(user);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _storage.setCurrentUser(null);
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String? email) async {
    if (_currentUser == null) return;
    
    final updatedUser = _currentUser!.copyWith(name: name, email: email);
    await _storage.saveUser(updatedUser);
    await _storage.setCurrentUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }
}
