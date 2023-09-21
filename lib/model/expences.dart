class Expense {
  final String description;
  final DateTime date;
  final double amount;

  Expense({
    required this.description,
    required this.date,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      description: json['description'],
      date: DateTime.parse(json['date']),
      amount: json['amount'],
    );
  }
}
