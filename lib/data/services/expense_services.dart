import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final http.Client _client;

  ExpenseService({http.Client? client}) : _client = client ?? http.Client();


  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  void _handleStatus(http.Response response) {
    if (response.statusCode == 404) throw const NotFoundException();
    if (response.statusCode >= 500) {
      throw ServerException('Server error.', statusCode: response.statusCode);
    }
    if (response.statusCode >= 400) {
      throw AppException(
        'Request failed: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }


  Future<List<ExpenseModel>> fetchExpenses() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConstants.expensesEndpoint), headers: _headers)
          .timeout(const Duration(seconds: 15));

      _handleStatus(response);

      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Could not reach the server. Check your connection.');
    }
  }

  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiConstants.expensesEndpoint),
            headers: _headers,
            body: json.encode(expense.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      _handleStatus(response);

      return ExpenseModel.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to create expense.');
    }
  }

  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    assert(expense.id != null, 'Cannot update an expense without an id.');
    try {
      final response = await _client
          .put(
            Uri.parse(ApiConstants.expenseById(expense.id!)),
            headers: _headers,
            body: json.encode(expense.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      _handleStatus(response);

      return ExpenseModel.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to update expense.');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(ApiConstants.expenseById(id)),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 15));

      _handleStatus(response);
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to delete expense.');
    }
  }
}