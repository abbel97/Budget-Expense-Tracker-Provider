import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/expense_model.dart';
import '../../providers/expense_provider.dart';

class AddExpenseSheet extends StatefulWidget {
  final ExpenseModel? existing;

  const AddExpenseSheet({super.key, this.existing});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _titleCtrl  = TextEditingController();
  final _amountCtrl = TextEditingController();

  String _type     = 'expense';
  String _category = kExpenseCategories.first;
  bool   _isSaving = false;

  // static const _purple   = Color(0xFF7C3AED);
  static const _income   = Color(0xFF22C55E);
  static const _expense  = Color(0xFFEF4444);
  static const _surface  = Color(0xFF1A1830);
  static const _card     = Color(0xFF1E1C32);
  static const _divider  = Color(0xFF2D2B45);
  static const _textSub  = Color(0xFF9CA3AF);
  static const _textHint = Color(0xFF6B7280);

  bool get _isEdit => widget.existing != null;

  List<String> get _categories =>
      _type == 'income' ? kIncomeCategories : kExpenseCategories;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e  = widget.existing!;
      _type     = e.type;
      _category = e.category;
      _titleCtrl.text  = e.title;
      _amountCtrl.text = e.amount.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<ExpenseProvider>();
    final expense  = ExpenseModel(
      id:       widget.existing?.id,
      title:    _titleCtrl.text.trim(),
      amount:   double.parse(_amountCtrl.text.trim()),
      type:     _type,
      category: _category,
      date:     _isEdit
                  ? widget.existing!.date
                  : DateTime.now().toIso8601String(),
    );

    final success = _isEdit
        ? await provider.updateExpense(expense)
        : await provider.addExpense(expense);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Something went wrong.'),
          backgroundColor: _expense,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final activeColor = _type == 'income' ? _income : _expense;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomInset + 28),
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            Text(
              _isEdit ? 'Edit Transaction' : 'Add Transaction',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildToggle('income', 'Income',
                      Icons.arrow_upward_rounded, _income),
                  _buildToggle('expense', 'Expense',
                      Icons.arrow_downward_rounded, _expense),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const _Label('Category'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _categories.contains(_category)
                  ? _category
                  : _categories.first,
              dropdownColor: _card,
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: _textHint,
              decoration: InputDecoration(
                filled: true,
                fillColor: _card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Text(kCategoryEmoji[c] ?? '💰',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Text(c),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            const _Label('Title'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: _type == 'income'
                    ? 'e.g. Monthly Salary'
                    : 'e.g. Coffee Lab',
                hintStyle: const TextStyle(color: _textHint),
                filled: true,
                fillColor: _card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: activeColor, width: 1.5),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Title is required.'
                  : null,
            ),
            const SizedBox(height: 16),

            const _Label('Amount'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: const TextStyle(color: _textHint),
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                  color: activeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: _card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: activeColor, width: 1.5),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required.';
                if (double.tryParse(v.trim()) == null) return 'Enter a valid number.';
                if (double.parse(v.trim()) <= 0) return 'Amount must be greater than 0.';
                return null;
              },
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEdit ? 'Save Changes' : 'Add Transaction',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(
      String type, String label, IconData icon, Color color) {
    final selected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _type     = type;
          _category = (type == 'income'
                  ? kIncomeCategories
                  : kExpenseCategories)
              .first;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: color.withOpacity(0.5))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? color : _textHint, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? color : _textSub,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );
}