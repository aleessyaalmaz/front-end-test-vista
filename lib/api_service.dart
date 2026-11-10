import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

// Chrome / iOS simulator: localhost
// Android emulator: change to http://10.0.2.2:3000
const baseUrl = 'http://localhost:3000';

class ApiService {
  Exception _error(http.Response r) {
    try {
      final b = jsonDecode(r.body);
      if (b['message'] != null) return Exception(b['message']);
      if (b['errors'] != null) return Exception(b['errors'][0]['msg']);
    } catch (_) {}
    return Exception('Request failed (${r.statusCode})');
  }

  Future<List<Company>> getCompanies() async {
    final r = await http.get(Uri.parse('$baseUrl/companies'));
    if (r.statusCode != 200) throw _error(r);
    return (jsonDecode(r.body) as List).map((c) => Company.fromJson(c)).toList();
  }

  Future<void> createCompany(String name, String reg) async {
    final r = await http.post(
      Uri.parse('$baseUrl/companies'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'registrationNumber': reg}),
    );
    if (r.statusCode != 201) throw _error(r);
  }

  Future<void> createService(
      int companyId, String name, String desc, double price) async {
    final r = await http.post(
      Uri.parse('$baseUrl/services'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'companyId': companyId,
        'name': name,
        'description': desc,
        'price': price,
      }),
    );
    if (r.statusCode != 201) throw _error(r);
  }
}