import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _currentUser != null;

  Future<void> loadSavedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    
    if (_token != null) {
      _apiService.setToken(_token);
      final response = await _apiService.getCurrentUser();
      if (response['status'] == 'success') {
        _currentUser = User.fromJson(response['user']);
      } else {
        _token = null;
        await prefs.remove('token');
      }
    }
  }

  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    final response = await _apiService.signup(name, email, password);
    
    if (response['status'] == 'success') {
      _token = response['token'];
      _currentUser = User.fromJson(response['user']);
      _apiService.setToken(_token);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    }
    
    return response;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    
    if (response['status'] == 'success') {
      _token = response['token'];
      _currentUser = User.fromJson(response['user']);
      _apiService.setToken(_token);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    }
    
    return response;
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _apiService.setToken(null);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}

