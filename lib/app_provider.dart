import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';

class AppProvider extends ChangeNotifier {
  final _api = ApiService();
  List<Company> companies = [];
  bool isLoading = false;
  String? error;

  Future<void> loadCompanies() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      companies = await _api.getCompanies();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  // Returns null on success, or an error message
  Future<String?> _run(Future<void> Function() action) async {
    isLoading = true;
    notifyListeners();
    try {
      await action();
      await loadCompanies();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString().replaceFirst('Exception: ', '');
    }
  }

  Future<String?> createCompany(String name, String reg) =>
      _run(() => _api.createCompany(name, reg));

  Future<String?> createService(
          int companyId, String name, String desc, double price) =>
      _run(() => _api.createService(companyId, name, desc, price));
}