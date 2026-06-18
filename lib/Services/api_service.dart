import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/goat_model.dart';
import '../Models/dashboard_models.dart';
import '../Models/expense_model.dart';
import '../Models/breeding_model.dart';
import '../Models/health_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// INLINE MODELS  (for endpoints that had stub classes with no fromJson)
// ─────────────────────────────────────────────────────────────────────────────

class SalesModel {
  final int id;
  final int? goatId;
  final String buyerName;
  final double amountReceived;
  final String paymentMethod;
  final String dateSold;
  final String notes;

  SalesModel({
    required this.id,
    this.goatId,
    required this.buyerName,
    required this.amountReceived,
    required this.paymentMethod,
    required this.dateSold,
    required this.notes,
  });

  factory SalesModel.fromJson(Map<String, dynamic> j) => SalesModel(
        id: j['id'] ?? 0,
        goatId: j['goat'],
        buyerName: j['buyer_name'] ?? '',
        amountReceived:
            double.tryParse(j['amount_received']?.toString() ?? '0') ?? 0,
        paymentMethod: j['payment_method'] ?? 'CASH',
        dateSold: j['date_sold'] ?? '',
        notes: j['notes'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        if (goatId != null) 'goat': goatId,
        'buyer_name': buyerName,
        'amount_received': amountReceived,
        'payment_method': paymentMethod,
        'notes': notes,
      };
}

class ChatMessageModel {
  final int id;
  final String senderUsername;
  final String text;
  final DateTime createdAt;
  final bool isMe;

  ChatMessageModel({
    required this.id,
    required this.senderUsername,
    required this.text,
    required this.createdAt,
    required this.isMe,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> j) =>
      ChatMessageModel(
        id: j['id'] ?? 0,
        senderUsername: j['sender_username'] ?? '',
        text: j['text'] ?? '',
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at']) ?? DateTime.now()
            : DateTime.now(),
        isMe: j['is_me'] ?? false,
      );
}

// fromJson helpers for stub models
Expense expenseFromJson(Map<String, dynamic> j) => Expense(
      id: j['id']?.toString() ?? '0',
      title: j['title'] ?? '',
      amount: double.tryParse(j['amount']?.toString() ?? '0') ?? 0,
      date: j['date'] != null
          ? DateTime.tryParse(j['date']) ?? DateTime.now()
          : DateTime.now(),
      category: j['category'] ?? 'FEED',
    );

Breeding breedingFromJson(Map<String, dynamic> j) => Breeding(
      id: j['id']?.toString() ?? '0',
      motherId: j['mother']?.toString() ?? '',
      fatherId: j['father_tag_id'] ?? '',
      breedingDate: j['breeding_date'] != null
          ? DateTime.tryParse(j['breeding_date']) ?? DateTime.now()
          : DateTime.now(),
      expectedBirth: j['expected_birth'] != null
          ? DateTime.tryParse(j['expected_birth']) ??
              DateTime.now().add(const Duration(days: 150))
          : DateTime.now().add(const Duration(days: 150)),
      kidsBorn: j['kids_born'] ?? 0,
    );

HealthRecord healthFromJson(Map<String, dynamic> j) => HealthRecord(
      id: j['id']?.toString() ?? '0',
      goatId: j['goat']?.toString() ?? '',
      treatment: j['treatment'] ?? '',
      date: j['date_administered'] != null
          ? DateTime.tryParse(j['date_administered']) ?? DateTime.now()
          : DateTime.now(),
      notes: j['notes'] ?? '',
    );

// ─────────────────────────────────────────────────────────────────────────────
// CENTRAL API SERVICE
// ─────────────────────────────────────────────────────────────────────────────
class ApiService {
  // ── Base URL ───────────────────────────────────────────────────────────────
  //
  static const String _webUrl      = 'http://localhost:8000/api/';
  static const String _emulatorUrl = 'http://10.0.2.2:8000/api/';

  // ↓↓↓  CHANGE THIS TO YOUR PC's IP ADDRESS  ↓↓↓
  static const String _deviceUrl   = 'http://192.168.1.18:8000/api/';
  // ↑↑↑  CHANGE THIS TO YOUR PC's IP ADDRESS  ↑↑↑

  static String get baseUrl {
    if (kIsWeb) return _webUrl;
    return _deviceUrl;  // real phone
    // return _emulatorUrl;  // Android emulator only
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('auth_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final t = await getToken();
      if (t != null) h['Authorization'] = 'Token $t';
    }
    return h;
  }

  static Future<void> _persist(Map<String, dynamic> data) async {
    final p = await SharedPreferences.getInstance();
    if (data['token'] != null) await p.setString('auth_token', data['token']);
    if (data['username'] != null)
      await p.setString('username', data['username']);
    if (data['email'] != null) await p.setString('email', data['email']);
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('auth_token');
    await p.remove('username');
    await p.remove('email');
  }

  static Future<bool> isLoggedIn() async {
    final t = await getToken();
    return t != null && t.isNotEmpty;
  }

  // ── 1. AUTH ────────────────────────────────────────────────────────────────

  /// POST /api/register/
  static Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('${baseUrl}register/'),
        headers: await _headers(auth: false),
        body: json
            .encode({'username': username, 'email': email, 'password': password}),
      );
      final data = json.decode(res.body);
      if (res.statusCode == 201) {
        await _persist(data);
        return {'success': true, 'token': data['token']};
      }
      return {
        'success': false,
        'error': data['error'] ?? 'Registration failed'
      };
    } catch (_) {
      return {'success': false, 'error': 'Cannot reach server.'};
    }
  }

  /// POST /api/login/
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('${baseUrl}login/'),
        headers: await _headers(auth: false),
        body: json.encode({'username': username, 'password': password}),
      );
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        await _persist(data);
        return {'success': true, 'token': data['token']};
      }
      return {
        'success': false,
        'error': data['error'] ?? 'Invalid credentials'
      };
    } catch (_) {
      return {'success': false, 'error': 'Cannot reach server.'};
    }
  }

  /// POST /api/password-reset/request/
  static Future<Map<String, dynamic>> requestPasswordReset(
      String email) async {
    try {
      final res = await http.post(
        Uri.parse('${baseUrl}password-reset/request/'),
        headers: await _headers(auth: false),
        body: json.encode({'email': email}),
      );
      final data = json.decode(res.body);
      return res.statusCode == 200
          ? {'success': true, 'message': data['message']}
          : {'success': false, 'error': data['error'] ?? 'Request failed'};
    } catch (_) {
      return {'success': false, 'error': 'Cannot reach server.'};
    }
  }

  /// POST /api/password-reset/confirm/
  static Future<Map<String, dynamic>> confirmPasswordReset({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${baseUrl}password-reset/confirm/'),
        headers: await _headers(auth: false),
        body: json.encode({
          'email': email,
          'otp_code': otpCode,
          'new_password': newPassword
        }),
      );
      final data = json.decode(res.body);
      return res.statusCode == 200
          ? {'success': true, 'message': data['message']}
          : {
              'success': false,
              'error': data['error'] ?? 'Invalid or expired PIN'
            };
    } catch (_) {
      return {'success': false, 'error': 'Cannot reach server.'};
    }
  }

  /// POST /api/change-password/
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${baseUrl}change-password/'),
        headers: await _headers(),
        body: json.encode(
            {'old_password': oldPassword, 'new_password': newPassword}),
      );
      final data = json.decode(res.body);
      return res.statusCode == 200
          ? {'success': true, 'message': data['message']}
          : {
              'success': false,
              'error': data['error'] ?? 'Failed to change password'
            };
    } catch (_) {
      return {'success': false, 'error': 'Cannot reach server.'};
    }
  }

  // ── 2. GOATS  /api/goats/ ──────────────────────────────────────────────────

  static Future<List<GoatModel>> fetchGoats() async {
    final res =
        await http.get(Uri.parse('${baseUrl}goats/'), headers: await _headers());
    if (res.statusCode == 200) {
      return (json.decode(res.body) as List)
          .map((i) => GoatModel.fromJson(i))
          .toList();
    }
    throw Exception('Failed to load goats (${res.statusCode})');
  }

  static Future<bool> addGoat(GoatModel goat) async {
    try {
      final res = await http.post(Uri.parse('${baseUrl}goats/'),
          headers: await _headers(), body: json.encode(goat.toJson()));
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateGoat(int id, Map<String, dynamic> data) async {
    try {
      final res = await http.patch(Uri.parse('${baseUrl}goats/$id/'),
          headers: await _headers(), body: json.encode(data));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteGoat(int id) async {
    try {
      final res = await http.delete(Uri.parse('${baseUrl}goats/$id/'),
          headers: await _headers());
      return res.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // ── 3. TASKS  /api/tasks/ ──────────────────────────────────────────────────

  static Future<List<TaskModel>> fetchTasks() async {
    try {
      final res = await http.get(Uri.parse('${baseUrl}tasks/'),
          headers: await _headers());
      if (res.statusCode == 200) {
        return (json.decode(res.body) as List)
            .map((i) => TaskModel.fromJson(i))
            .toList();
      }
      throw Exception('Failed to load tasks');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> toggleTaskStatus(int taskId, bool currentStatus) async {
    try {
      final res = await http.patch(Uri.parse('${baseUrl}tasks/$taskId/'),
          headers: await _headers(),
          body: json.encode({'is_done': !currentStatus}));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> createTask({
    required String title,
    String description = '',
    String priority = 'medium',
  }) async {
    try {
      final res = await http.post(Uri.parse('${baseUrl}tasks/'),
          headers: await _headers(),
          body: json.encode({
            'title': title,
            'description': description,
            'priority': priority
          }));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ── 4. ALERTS  /api/alerts/ ────────────────────────────────────────────────

  static Future<List<AlertModel>> fetchLiveAlerts() async {
    try {
      final res = await http.get(Uri.parse('${baseUrl}alerts/'),
          headers: await _headers());
      if (res.statusCode == 200) {
        return (json.decode(res.body) as List)
            .map((i) => AlertModel.fromJson(i))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ── 5. EXPENSES  /api/expenses/ ────────────────────────────────────────────

  static Future<List<Expense>> fetchExpenses() async {
    try {
      final res = await http.get(Uri.parse('${baseUrl}expenses/'),
          headers: await _headers());
      if (res.statusCode == 200) {
        return (json.decode(res.body) as List)
            .map((i) => expenseFromJson(i))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> addExpense({
    required String title,
    required double amount,
    required String category,
  }) async {
    try {
      final res = await http.post(Uri.parse('${baseUrl}expenses/'),
          headers: await _headers(),
          body: json
              .encode({'title': title, 'amount': amount, 'category': category}));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteExpense(int id) async {
    try {
      final res = await http.delete(Uri.parse('${baseUrl}expenses/$id/'),
          headers: await _headers());
      return res.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  // ── 6. SALES  /api/sales/ ──────────────────────────────────────────────────

  static Future<List<SalesModel>> fetchSales() async {
    try {
      final res = await http.get(Uri.parse('${baseUrl}sales/'),
          headers: await _headers());
      if (res.statusCode == 200) {
        return (json.decode(res.body) as List)
            .map((i) => SalesModel.fromJson(i))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> recordSale(SalesModel sale) async {
    try {
      final res = await http.post(Uri.parse('${baseUrl}sales/'),
          headers: await _headers(), body: json.encode(sale.toJson()));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ── 7. BREEDING  /api/breeding/ ────────────────────────────────────────────

  static Future<List<Breeding>> fetchBreedingRecords() async {
    try {
      final res = await http.get(Uri.parse('${baseUrl}breeding/'),
          headers: await _headers());
      if (res.statusCode == 200) {
        return (json.decode(res.body) as List)
            .map((i) => breedingFromJson(i))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> logBreedingEvent({
    required int motherId,
    required String fatherTagId,
    required String breedingDate,
  }) async {
    try {
      final res = await http.post(Uri.parse('${baseUrl}breeding/'),
          headers: await _headers(),
          body: json.encode({
            'mother': motherId,
            'father_tag_id': fatherTagId,
            'breeding_date': breedingDate
          }));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ── 8. HEALTH  /api/health/ ────────────────────────────────────────────────

  static Future<List<HealthRecord>> fetchHealthRecords() async {
    try {
      final res = await http.get(Uri.parse('${baseUrl}health/'),
          headers: await _headers());
      if (res.statusCode == 200) {
        return (json.decode(res.body) as List)
            .map((i) => healthFromJson(i))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> addHealthRecord({
    required int goatId,
    required String treatment,
    String notes = '',
  }) async {
    try {
      final res = await http.post(Uri.parse('${baseUrl}health/'),
          headers: await _headers(),
          body: json.encode(
              {'goat': goatId, 'treatment': treatment, 'notes': notes}));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  // ── 9. CHAT  /api/chat/ ────────────────────────────────────────────────────

  static Future<List<ChatMessageModel>> fetchChatMessages() async {
    try {
      final res = await http.get(Uri.parse('${baseUrl}chat/'),
          headers: await _headers());
      if (res.statusCode == 200) {
        return (json.decode(res.body) as List)
            .map((i) => ChatMessageModel.fromJson(i))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> sendChatMessage(String text) async {
    try {
      final res = await http.post(Uri.parse('${baseUrl}chat/'),
          headers: await _headers(), body: json.encode({'text': text}));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// PATCH /api/chat/{id}/ — only the original sender may edit
  static Future<bool> editChatMessage(int id, String newText) async {
    try {
      final res = await http.patch(Uri.parse('${baseUrl}chat/$id/'),
          headers: await _headers(), body: json.encode({'text': newText}));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }


  /// DELETE /api/chat/{id}/ — only the original sender may delete
  static Future<bool> deleteChatMessage(int id) async {
    try {
      final res = await http.delete(Uri.parse('${baseUrl}chat/$id/'),
          headers: await _headers());
      return res.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
