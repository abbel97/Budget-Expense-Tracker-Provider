import 'package:flutter/foundation.dart';
import '../../data/models/expense_model.dart';
import '../data/services/expense_services.dart';

class ExpenseProvider extends ChangeNotifier {
  final _service = ExpenseService();

  List<ExpenseModel> _expenses = [];
  bool isLoading = false;
  String? errorMessage;

  List<ExpenseModel> get expenses => _expenses;

  double get totalIncome => _expenses
      .where((e) => e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpense => _expenses
      .where((e) => !e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);

  // Fetch all expenses from API
  Future<void> fetchExpenses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _service.fetchAll();
      _expenses.sort((a, b) {
        final da = DateTime.tryParse(a.date) ?? DateTime(0);
        final db = DateTime.tryParse(b.date) ?? DateTime(0);
        return db.compareTo(da);
      });
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // create
  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      final created = await _service.create(expense);
      _expenses.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // update
  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      final updated = await _service.update(expense);
      final index = _expenses.indexWhere((e) => e.id == updated.id);
      if (index != -1) _expenses[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // delete with optimistic update
  Future<bool> deleteExpense(String id) async {
    final backup = List<ExpenseModel>.from(_expenses);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();

    try {
      await _service.delete(id);
      return true;
    } catch (e) {
      _expenses = backup; // rollback
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}