import 'package:flutter/foundation.dart';
import '../data/models/expense_model.dart';
import '../data/services/expense_services.dart';
import '../core/errors/app_exception.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseService _service;

  ExpenseProvider({ExpenseService? service})
    : _service = service ?? ExpenseService();

  // State 
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserEmail;

  // Getters 
  List<ExpenseModel> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setCurrentUserEmail(String email) {
    _currentUserEmail = email.trim().toLowerCase();
    _expenses = [];
    notifyListeners();
  }

  void clearCurrentUser() {
    _currentUserEmail = null;
    _expenses = [];
    notifyListeners();
  }

  double get totalIncome =>
      _expenses.where((e) => e.isIncome).fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpense =>
      _expenses.where((e) => !e.isIncome).fold(0.0, (sum, e) => sum + e.amount);

  double get totalSaved => totalIncome - totalExpense;


  // Returns daily expense totals for the current week (Mon–Sun).
  // Index 0 = Monday … 6 = Sunday.
  List<double> get weeklyExpenseData {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final totals = List<double>.filled(7, 0.0);

    for (final e in _expenses) {
      if (e.isIncome) continue;
      final date = DateTime.tryParse(e.date);
      if (date == null) continue;
      final diff = date
          .toLocal()
          .difference(
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          )
          .inDays;
      if (diff >= 0 && diff < 7) {
        totals[diff] += e.amount;
      }
    }
    return totals;
  }

  // Returns daily expense totals for the current month (1 value per day).
  List<double> get monthlyExpenseData {
    final now = DateTime.now();
    final daysInMonth = DateTimeRange(
      start: DateTime(now.year, now.month),
      end: DateTime(now.year, now.month + 1),
    ).duration.inDays;
    final totals = List<double>.filled(daysInMonth, 0.0);

    for (final e in _expenses) {
      if (e.isIncome) continue;
      final date = DateTime.tryParse(e.date);
      if (date == null) continue;
      if (date.year == now.year && date.month == now.month) {
        totals[date.day - 1] += e.amount;
      }
    }
    return totals;
  }

  // Returns monthly expense totals for the current year (Jan–Dec).
  List<double> get yearlyExpenseData {
    final now = DateTime.now();
    final totals = List<double>.filled(12, 0.0);
    for (final e in _expenses) {
      if (e.isIncome) continue;
      final date = DateTime.tryParse(e.date);
      if (date == null) continue;
      if (date.year == now.year) {
        totals[date.month - 1] += e.amount;
      }
    }
    return totals;
  }

  //Private helpers 
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // CRUD 
  Future<void> fetchExpenses() async {
    if (_currentUserEmail == null || _currentUserEmail!.isEmpty) {
      _expenses = [];
      _setError(null);
      return;
    }
    _setLoading(true);
    _setError(null);
    try {
      final allExpenses = await _service.fetchExpenses();
      _expenses = allExpenses
          .where(
            (expense) =>
                expense.ownerEmail?.trim().toLowerCase() == _currentUserEmail,
          )
          .toList();
      //sort newest first
      _expenses.sort((a, b) {
        final da = DateTime.tryParse(a.date) ?? DateTime(0);
        final db = DateTime.tryParse(b.date) ?? DateTime(0);
        return db.compareTo(da);
      });
    } on AppException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createExpense(ExpenseModel expense) async {
    if (_currentUserEmail == null || _currentUserEmail!.isEmpty) {
      _setError('Please sign in before adding an expense.');
      return false;
    }
    _setError(null);
    try {
      final created = await _service.createExpense(
        expense.copyWith(ownerEmail: _currentUserEmail),
      );
      _expenses.insert(0, created);
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    if (expense.ownerEmail?.trim().toLowerCase() != _currentUserEmail) {
      _setError('You can only update your own expenses.');
      return false;
    }
    _setError(null);
    try {
      final updated = await _service.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        _expenses[index] = updated;
        notifyListeners();
      }
      return true;
    } on AppException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    if (_expenses.every((expense) => expense.id != id)) {
      _setError('You can only delete your own expenses.');
      return false;
    }
    _setError(null);
    final backup = List<ExpenseModel>.from(_expenses);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    try {
      await _service.deleteExpense(id);
      return true;
    } on AppException catch (e) {
      _expenses = backup;
      _setError(e.message);
      return false;
    }
  }
}

// Helper used inside the provider, avoids importing dart:core DateTimeRange
class DateTimeRange {
  final DateTime start;
  final DateTime end;
  const DateTimeRange({required this.start, required this.end});
  Duration get duration => end.difference(start);
}
