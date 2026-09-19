class ExpenseModel {
  final String? id;
  final String? ownerEmail;
  final String title;
  final double amount;
  final String type; // 'income' | 'expense'
  final String category;
  final String date; // ISO-8601 string

  const ExpenseModel({
    this.id,
    this.ownerEmail,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  bool get isIncome => type == 'income';

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id']?.toString(),
      ownerEmail: json['ownerEmail'] as String?,
      title: json['title'] as String? ?? '',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'] as String? ?? 'expense',
      category: json['category'] as String? ?? 'Others',
      date: json['date'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
    if (ownerEmail != null) 'ownerEmail': ownerEmail,
    'title': title,
    'amount': amount,
    'type': type,
    'category': category,
    'date': date,
  };

  ExpenseModel copyWith({
    String? id,
    String? ownerEmail,
    String? title,
    double? amount,
    String? type,
    String? category,
    String? date,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  @override
  String toString() =>
      'ExpenseModel(id: $id, title: $title, amount: $amount, type: $type)';
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

const Map<String, String> kCategoryIcons = {
  'Food & Drinks': '🍔',
  'Grocery': '🛒',
  'Transport': '🚗',
  'Entertainment': '🎬',
  'Health': '💊',
  'Fees': '🧾',
  'Salary': '💼',
  'Freelance': '💻',
  'Gift': '🎁',
  'Others': '💰',
};
