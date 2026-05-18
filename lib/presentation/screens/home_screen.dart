import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense_model.dart';
import '../../providers/expense_provider.dart';
import 'add_expense_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _monthlyBudget = 0.0;

  static const _purple     = Color(0xFF7C3AED);
  static const _purpleDeep = Color(0xFF6B21A8);
  static const _accent     = Color(0xFFC8F135);
  static const _income     = Color(0xFF22C55E);
  static const _expense    = Color(0xFFEF4444);
  static const _surface    = Color(0xFF1A1830);
  static const _divider    = Color(0xFF2D2B45);
  static const _textSub    = Color(0xFF9CA3AF);
  static const _textHint   = Color(0xFF6B7280);
  static const _deleteRed  = Color(0xFFDC2626);
  static const _editBlue   = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _loadBudget();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().fetchExpenses();
    });
  }

  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _monthlyBudget = prefs.getDouble('monthlyBudget') ?? 0.0);
  }

  void _openSheet({ExpenseModel? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(ExpenseModel expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete transaction',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete "${expense.title}"? This cannot be undone.',
          style: const TextStyle(color: _textSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: _textSub)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: _expense)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<ExpenseProvider>().deleteExpense(expense.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final totalBalance =
        _monthlyBudget + provider.totalIncome - provider.totalExpense;
    final fmt = NumberFormat('#,##0.00', 'en_US');

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: _purple,
          backgroundColor: _surface,
          onRefresh: () => provider.fetchExpenses(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'EXPENSE TRACKER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_purpleDeep, _purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'AVAILABLE FUNDS',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              DateFormat('MMMM yyyy')
                                  .format(DateTime.now())
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        provider.isLoading
                            ? const SizedBox(
                                height: 44,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white54,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : RichText(
                                text: TextSpan(children: [
                                  const TextSpan(
                                    text: '\$',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: fmt.format(totalBalance).split('.')[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 42,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '.${fmt.format(totalBalance).split('.')[1]}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ]),
                              ),

                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            _BalanceStat(
                              label: 'INCOME',
                              amount: provider.totalIncome,
                              color: _income,
                            ),
                            const SizedBox(width: 24),
                            _BalanceStat(
                              label: 'EXPENSES',
                              amount: provider.totalExpense,
                              color: _expense,
                              prefix: '-',
                            ),
                            const SizedBox(width: 24),
                            _BalanceStat(
                              label: 'SAVED',
                              amount: provider.totalIncome - provider.totalExpense,
                              color: _accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TRANSACTIONS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '${provider.expenses.length} total',
                        style: const TextStyle(color: _textHint, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              if (provider.errorMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _expense.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: _expense.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              color: _expense, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(
                                  color: _expense, fontSize: 13),
                            ),
                          ),
                          TextButton(
                            onPressed: () => provider.fetchExpenses(),
                            child: const Text('Retry',
                                style: TextStyle(color: _accent)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              if (provider.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _purple,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )

              else if (provider.expenses.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: const [
                        Icon(Icons.receipt_long_outlined,
                            color: _textHint, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'No transactions yet.\nTap + to add one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _textSub,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = provider.expenses[index];
                        final isLast =
                            index == provider.expenses.length - 1;

                        return Column(
                          children: [
                            _SwipeableItem(
                              expense: expense,
                              onEdit: () =>
                                  _openSheet(existing: expense),
                              onDelete: () => _confirmDelete(expense),
                              deleteColor: _deleteRed,
                              editColor: _editBlue,
                            ),
                            if (!isLast)
                              const Divider(
                                color: _divider,
                                height: 1,
                                indent: 60,
                              ),
                          ],
                        );
                      },
                      childCount: provider.expenses.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSheet(),
        backgroundColor: _accent,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String prefix;

  const _BalanceStat({
    required this.label,
    required this.amount,
    required this.color,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'en_US');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$prefix\$${fmt.format(amount.abs())}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SwipeableItem extends StatefulWidget {
  final ExpenseModel expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Color deleteColor;
  final Color editColor;

  const _SwipeableItem({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
    required this.deleteColor,
    required this.editColor,
  });

  @override
  State<_SwipeableItem> createState() => _SwipeableItemState();
}

class _SwipeableItemState extends State<_SwipeableItem> {
  double _offset = 0;
  static const double _revealWidth = 72.0;

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _offset = (_offset + d.delta.dx).clamp(-_revealWidth, _revealWidth);
    });
  }

  void _onDragEnd(DragEndDetails _) {
    final snapToReveal = _offset.abs() >= _revealWidth * 0.5;
    setState(() {
      _offset = snapToReveal
          ? (_offset < 0 ? -_revealWidth : _revealWidth)
          : 0;
    });
  }

  void _reset() => setState(() => _offset = 0);

  @override
  Widget build(BuildContext context) {
    final e = widget.expense;
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final date = DateTime.tryParse(e.date)?.toLocal() ?? DateTime.now();

    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: SizedBox(
        height: 72,
        child: Stack(
          children: [
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: widget.editColor,
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
                                color: Colors.white, size: 20),
                            SizedBox(height: 4),
                            Text('Edit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: widget.deleteColor,
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
                                color: Colors.white, size: 20),
                            SizedBox(height: 4),
                            Text('Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Transform.translate(
              offset: Offset(_offset, 0),
              child: Container(
                color: const Color(0xFF1E1C32),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Emoji icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: e.isIncome
                            ? const Color(0xFF22C55E).withOpacity(0.12)
                            : const Color(0xFF7C3AED).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          kCategoryEmoji[e.category] ?? '💰',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            e.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${e.category}  ·  ${DateFormat('MMM d, h:mm a').format(date)}',
                            style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '${e.isIncome ? '+' : '-'}\$${fmt.format(e.amount)}',
                      style: TextStyle(
                        color: e.isIncome
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
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