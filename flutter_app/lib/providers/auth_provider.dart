import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool get isAuthenticated => _authService.isAuthenticated;
  get currentUser => _authService.currentUser;
  String? get token => _authService.token;

  Future<void> initialize() async {
    await _authService.loadSavedAuth();
    notifyListeners();
  }

  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final result = await _authService.signup(name, email, password);
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final result = await _authService.login(email, password);
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}

