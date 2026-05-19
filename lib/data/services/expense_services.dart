import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/expense_model.dart';

class ExpenseService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept'       : 'application/json',
  };

  bool _ok(int status) => status >= 200 && status < 300;

  //READ
  Future<List<ExpenseModel>> fetchAll() async {
    final res = await http
        .get(Uri.parse(ApiConstants.expensesEndpoint), headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (!_ok(res.statusCode)) {
      throw Exception('Failed to load expenses. (${res.statusCode})');
    }

    final List data = json.decode(res.body);
    return data.map((e) => ExpenseModel.fromJson(e)).toList();
  }

  // CREATE
  Future<ExpenseModel> create(ExpenseModel expense) async {
    final res = await http
        .post(
          Uri.parse(ApiConstants.expensesEndpoint),
          headers: _headers,
          body: json.encode(expense.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (!_ok(res.statusCode)) {
      throw Exception('Failed to create expense. (${res.statusCode})');
    }
    return ExpenseModel.fromJson(json.decode(res.body));
  }

  // UPDATE
  Future<ExpenseModel> update(ExpenseModel expense) async {
    final res = await http
        .put(
          Uri.parse('${ApiConstants.expensesEndpoint}/${expense.id}'),
          headers: _headers,
          body: json.encode(expense.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (!_ok(res.statusCode)) {
      throw Exception('Failed to update expense. (${res.statusCode})');
    }
    return ExpenseModel.fromJson(json.decode(res.body));
  }

  // delete
  Future<void> delete(String id) async {
    final res = await http
        .delete(
          Uri.parse('${ApiConstants.expensesEndpoint}/$id'),
          headers: _headers,
        )
        .timeout(const Duration(seconds: 15));

    if (!_ok(res.statusCode)) {
      throw Exception('Failed to delete expense. (${res.statusCode})');
    }
  }
}