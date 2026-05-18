class ExpenseModel {
  final String? id;
  final String title;
  final double amount;
  final String type; 
  final String category;
  final String date;      

  const ExpenseModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  bool get isIncome => type == 'income';

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id']?.toString(),
        title: json['title'] as String? ?? '',
        amount: double.tryParse(json['amount'].toString()) ?? 0.0,
        type: json['type'] as String? ?? 'expense',
        category: json['category'] as String? ?? 'Others',
        date: json['date'] as String? ?? DateTime.now().toIso8601String(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
        'type': type,
        'category': category,
        'date': date,
      };

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    String? category,
    String? date,
  }) =>
      ExpenseModel(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        category: category ?? this.category,
        date: date ?? this.date,
      );
}

const List<String> kExpenseCategories = [
  'Food & Drinks',
  'Grocery',
  'Transport',
  'Entertainment',
  'Health',
  'Fees',
  'Others',
];

const List<String> kIncomeCategories = [
  'Salary',
  'Freelance',
  'Gift',
  'Others',
];

const Map<String, String> kCategoryEmoji = {
  'Food & Drinks': '🍔',
  'Grocery':       '🛒',
  'Transport':     '🚗',
  'Entertainment': '🎬',
  'Health':        '💊',
  'Fees':          '🧾',
  'Salary':        '💼',
  'Freelance':     '💻',
  'Gift':          '🎁',
  'Others':        '💰',
};