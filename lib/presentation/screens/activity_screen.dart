import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/expense_model.dart';
import '../../providers/expense_provider.dart';
import 'add_expense_sheet.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  // null = All, otherwise a specific type or category
  String? _activeFilter;

  static const List<String> _filterOptions = [
    'All',
    'Income',
    'Expenses',
    'Food & Drinks',
    'Grocery',
    'Transport',
  ];

  List<ExpenseModel> _filtered(List<ExpenseModel> all) {
    if (_activeFilter == null || _activeFilter == 'All') return all;
    if (_activeFilter == 'Income') return all.where((e) => e.isIncome).toList();
    if (_activeFilter == 'Expenses') return all.where((e) => !e.isIncome).toList();
    return all.where((e) => e.category == _activeFilter).toList();
  }

  /// Group transactions by date label (Today, Yesterday, date string).
  Map<String, List<ExpenseModel>> _grouped(List<ExpenseModel> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<ExpenseModel>> groups = {};
    for (final item in items) {
      final date = DateTime.tryParse(item.date)?.toLocal() ?? now;
      final dateOnly = DateTime(date.year, date.month, date.day);

      String label;
      if (dateOnly == today) {
        label = 'TODAY — ${DateFormat('MMM d').format(date).toUpperCase()}';
      } else if (dateOnly == yesterday) {
        label = 'YESTERDAY — ${DateFormat('MMM d').format(date).toUpperCase()}';
      } else {
        label = DateFormat('MMM d').format(date).toUpperCase();
      }

      groups.putIfAbsent(label, () => []);
      groups[label]!.add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final filtered = _filtered(provider.expenses);
    final grouped = _grouped(filtered);

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.purpleEnd,
        backgroundColor: AppColors.surface,
        onRefresh: () => provider.fetchExpenses(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'ACTIVITY',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'TRANSACTIONS',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      'Track every dollar in and out',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Income + Expense summary cards 
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'INCOME',
                            amount: provider.totalIncome,
                            color: AppColors.income,
                            isLoading: provider.isLoading,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            label: 'EXPENSES',
                            amount: provider.totalExpense,
                            color: AppColors.expense,
                            isLoading: provider.isLoading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filter tabs
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filterOptions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final label = _filterOptions[i];
                          final selected = (_activeFilter == null && label == 'All') ||
                              _activeFilter == label;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _activeFilter = label == 'All' ? null : label;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.accent
                                    : AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                label.toUpperCase(),
                                style: TextStyle(
                                  color: selected
                                      ? Colors.black
                                      : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Error state 
            if (provider.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.expense.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            color: AppColors.expense, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: const TextStyle(
                                color: AppColors.expense, fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => provider.fetchExpenses(),
                          child: const Text('Retry',
                              style: TextStyle(color: AppColors.accent)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Loading state 
            if (provider.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.purpleEnd,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )

            // Empty state 
            else if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          color: AppColors.textHint, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        _activeFilter == null
                            ? 'No transactions yet.\nTap + to add one.'
                            : 'No transactions for this filter.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )

            // Transaction list 
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final keys = grouped.keys.toList();
                    final dateLabel = keys[index];
                    final items = grouped[dateLabel]!;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Date group label
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              dateLabel,
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                          ),

                          // Transactions
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: items.asMap().entries.map((entry) {
                                final isLast = entry.key == items.length - 1;
                                return Column(
                                  children: [
                                    _SwipeableTransaction(
                                      expense: entry.value,
                                      onDelete: () => _confirmDelete(
                                          context, entry.value),
                                      onEdit: () => _openEdit(
                                          context, entry.value),
                                    ),
                                    if (!isLast)
                                      const Divider(
                                        color: AppColors.divider,
                                        height: 1,
                                        indent: 60,
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: grouped.keys.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, ExpenseModel expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete transaction',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Delete "${expense.title}"? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<ExpenseProvider>().deleteExpense(expense.id!);
    }
  }

  void _openEdit(BuildContext context, ExpenseModel expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(existing: expense),
    );
  }
}

// Summary Card 
class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isLoading;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_US');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          isLoading
              ? const SizedBox(
                  height: 28,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.purpleEnd,
                      strokeWidth: 1.5,
                    ),
                  ),
                )
              : Text(
                  '\$${fmt.format(amount)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ],
      ),
    );
  }
}

// Swipeable Transaction Item 
class _SwipeableTransaction extends StatefulWidget {
  final ExpenseModel expense;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _SwipeableTransaction({
    required this.expense,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_SwipeableTransaction> createState() => _SwipeableTransactionState();
}

class _SwipeableTransactionState extends State<_SwipeableTransaction> {
  double _offset = 0;
  static const double _threshold = 72.0;

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _offset = (_offset + d.delta.dx).clamp(-_threshold, _threshold);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_offset <= -_threshold) {
      // Snap to delete
      setState(() => _offset = -_threshold);
    } else if (_offset >= _threshold) {
      // Snap to edit
      setState(() => _offset = _threshold);
    } else {
      // Snap back
      setState(() => _offset = 0);
    }
  }

  void _reset() => setState(() => _offset = 0);

  @override
  Widget build(BuildContext context) {
    final expense = widget.expense;
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final date = DateTime.tryParse(expense.date)?.toLocal() ?? DateTime.now();
    final timeStr = DateFormat('h:mm a').format(date);

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          children: [

            // Background actions 
            Positioned.fill(
              child: Row(
                children: [

                  // Edit reveal (swipe right)
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: _offset > 0 ? 1.0 : 0.0,
                      child: Container(
                        color: AppColors.editBlue,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: GestureDetector(
                          onTap: () {
                            _reset();
                            widget.onEdit();
                          },
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined,
                                  color: Colors.white, size: 22),
                              SizedBox(height: 4),
                              Text('Edit',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Delete reveal (swipe left)
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: _offset < 0 ? 1.0 : 0.0,
                      child: Container(
                        color: AppColors.deleteRed,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: () {
                            _reset();
                            widget.onDelete();
                          },
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_outline,
                                  color: Colors.white, size: 22),
                              SizedBox(height: 4),
                              Text('Delete',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Foreground tile 
            Transform.translate(
              offset: Offset(_offset, 0),
              child: Container(
                color: AppColors.card,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [

                    // Category icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: expense.isIncome
                            ? AppColors.income.withValues(alpha:0.12)
                            : AppColors.purpleEnd.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          kCategoryIcons[expense.category] ?? '💰',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title + category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            expense.category,
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount + time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${expense.isIncome ? '+' : '-'}\$${fmt.format(expense.amount)}',
                          style: TextStyle(
                            color: expense.isIncome
                                ? AppColors.income
                                : AppColors.expense,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}