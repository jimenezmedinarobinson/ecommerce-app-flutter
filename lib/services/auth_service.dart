import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api/auth';
  static const String _tokenKey = 'admin_token';
  static const String _adminKey = 'admin_data';

  Future<Admin?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final admin = Admin.fromJson(data['admin']);
        await _saveAuthData(data['token'], admin);
        return admin;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      print('❌ Error de login: $e');
      rethrow;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/verify'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Admin?> getAdmin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminJson = prefs.getString(_adminKey);
      if (adminJson == null) return null;
      final Map<String, dynamic> data = jsonDecode(adminJson);
      return Admin.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAuthData(String token, Admin admin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_adminKey, jsonEncode(admin.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_adminKey);
  }
}
