import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://hope-ball-isolation-injured.trycloudflare.com/api";

  static String? _token;

  static Map<String, String> get _headers => {
        "Content-Type": "application/json",
        if (_token != null) "Authorization": "Bearer $_token",
      };

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static bool get hasToken => _token != null;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 || response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Login failed");
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String roleId,
    required String firstName,
    required String lastName,
    required String nationalId,
    required String phone,
    String? middleName,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "roleId": roleId,
        "firstName": firstName,
        "lastName": lastName,
        "nationalId": nationalId,
        "phone": phone,
        if (middleName != null) "middleName": middleName,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 || response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Registration failed");
    }
  }

  Future<Map<String, dynamic>> deposit({
    required String accountNumber,
    required String amount,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/transactions/deposit"),
      headers: _headers,
      body: jsonEncode({
        "accountNumber": accountNumber,
        "amount": amount,
        if (description != null) "description": description,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 || response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Deposit failed");
    }
  }

  Future<Map<String, dynamic>> withdraw({
    required String accountNumber,
    required String amount,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/transactions/withdraw"),
      headers: _headers,
      body: jsonEncode({
        "accountNumber": accountNumber,
        "amount": amount,
        if (description != null) "description": description,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 || response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Withdrawal failed");
    }
  }

  Future<Map<String, dynamic>> transfer({
    required String senderAccountNumber,
    required String receiverAccountNumber,
    required String amount,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/transactions/transfer"),
      headers: _headers,
      body: jsonEncode({
        "senderAccountNumber": senderAccountNumber,
        "receiverAccountNumber": receiverAccountNumber,
        "amount": amount,
        if (description != null) "description": description,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 || response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["message"] ?? "Transfer failed");
    }
  }
}