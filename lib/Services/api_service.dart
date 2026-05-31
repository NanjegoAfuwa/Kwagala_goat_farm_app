import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// 1. FIXED: Explicitly pull in your data models folder so Dart can read 'GoatModel'
import '../Models/goat_model.dart';
import '../Models/dashboard_models.dart'; 

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/";

  // REGISTER AN ACCOUNT
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}register/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        return {"success": true, "token": data['token']};
      } else {
        return {"success": false, "error": data['error'] ?? "Registration failed"};
      }
    } catch (e) {
      return {"success": false, "error": "Cannot reach backend server. Make sure Django is running!"};
    }
  }

  // LOGIN & OBTAIN TOKEN
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}login/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": username,
          "password": password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        return {"success": true, "token": data['token']};
      } else {
        return {"success": false, "error": data['error'] ?? "Invalid username or password credentials"};
      }
    } catch (e) {
      return {"success": false, "error": "Cannot reach backend server. Make sure Django is running!"};
    }
  }

  // REQUEST PASSWORD RESET OTP
  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}password-reset/request/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email}),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {"success": true, "message": data['message'] ?? "A verification code has been dispatched."};
      } else {
        return {"success": false, "error": data['error'] ?? "Failed to process request."};
      }
    } catch (e) {
      return {"success": false, "error": "Cannot reach backend server. Verify your connection."};
    }
  }

  // CONFIRM PASSWORD RESET (Production Variant)
  static Future<Map<String, dynamic>> confirmPasswordReset({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}password-reset/confirm/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "otp_code": otpCode,
          "new_password": newPassword,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          "success": true, 
          "message": data['message'] ?? "Password updated successfully!"
        };
      } else {
        return {
          "success": false, 
          "error": data['error'] ?? "Invalid or expired verification PIN."
        };
      }
    } catch (e) {
      return {"success": false, "error": "Unable to communicate with authentication nodes."};
    }
  }

  // 2. FETCH GOAT LISTINGS (Newly fixed model references)
  static Future<List<GoatModel>> fetchGoats() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("${baseUrl}goats/"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Token $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => GoatModel.fromJson(item)).toList();
      } else {
        throw Exception("Failed to pull live livestock telemetry array updates.");
      }
    } catch (e) {
      throw Exception("Unable to establish communication stream pipeline: $e");
    }
  }

  // ADD NEW GOAT RECORD
  static Future<bool> addGoat(GoatModel goat) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse("${baseUrl}goats/"),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Token $token",
        },
        body: json.encode(goat.toJson()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // UTILITY METHODS
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // FETCH ACTIVE ALERTS
  static Future<List<AlertModel>> fetchLiveAlerts() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("${baseUrl}alerts/"),
        headers: {"Authorization": "Token $token", "Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((item) => AlertModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return []; // Return empty list silently if network dips to avoid crashing dashboard tickers
    }
  }

  // FETCH ALL OPERATIONAL TASKS
  static Future<List<TaskModel>> fetchTasks() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse("${baseUrl}tasks/"),
        headers: {"Authorization": "Token $token", "Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((item) => TaskModel.fromJson(item)).toList();
      }
      throw Exception("Failed to load tasks");
    } catch (e) {
      throw Exception("Network error loading dashboard tasks: $e");
    }
  }

  // TOGGLE TASK COMPLETION STATUS (PATCH)
  static Future<bool> toggleTaskStatus(int taskId, bool currentStatus) async {
    try {
      final token = await getToken();
      final response = await http.patch(
        Uri.parse("${baseUrl}tasks/$taskId/"),
        headers: {"Authorization": "Token $token", "Content-Type": "application/json"},
        body: json.encode({"is_done": !currentStatus}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}