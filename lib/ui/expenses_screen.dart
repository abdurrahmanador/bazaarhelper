import 'dart:convert';
import 'package:bazaarhelper_final/state_holder_controller.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_nav_bar_screen.dart';

class Expense {
  final String description;
  final double amount;
  final DateTime date;

  Expense({
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      description: json['description'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
    );
  }
}

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  double _monthlyBudget = 1000.0;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  List<Expense> _expenses = [];

  @override
  void initState() {
    super.initState();
    _loadMonthlyBudget();
    _loadExpenses();
  }

  _loadMonthlyBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double savedBudget = prefs.getDouble('monthlyBudget') ?? 1000.0;
    setState(() {
      _monthlyBudget = savedBudget;
      _budgetController.text = _monthlyBudget.toString();
    });
  }

  _saveMonthlyBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyBudget', _monthlyBudget);
  }

  _loadExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> expensesJson = prefs.getStringList('expenses') ?? [];
    setState(() {
      _expenses = expensesJson.map((expenseJson) {
        return Expense.fromJson(Map<String, dynamic>.from(jsonDecode(expenseJson)));
      }).toList();
    });
  }

  _saveExpense(Expense expense) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> expensesJson = prefs.getStringList('expenses') ?? [];
    expensesJson.add(jsonEncode(expense.toJson()));
    await prefs.setStringList('expenses', expensesJson);
    _loadExpenses();
  }

  _deleteExpense(Expense expense) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> expensesJson = prefs.getStringList('expenses') ?? [];
    expensesJson.removeWhere((expenseJson) {
      final expenseData = jsonDecode(expenseJson);
      return Expense.fromJson(expenseData).date == expense.date;
    });
    await prefs.setStringList('expenses', expensesJson);
    _loadExpenses();
  }

  _updateExpense(Expense oldExpense, Expense updatedExpense) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> expensesJson = prefs.getStringList('expenses') ?? [];

    // Find the index of the old expense
    int index = expensesJson.indexWhere((expenseJson) {
      final expenseData = jsonDecode(expenseJson);
      return Expense.fromJson(expenseData).date == oldExpense.date;
    });

    if (index >= 0) {
      // Remove the old expense
      expensesJson.removeAt(index);

      // Add the updated expense
      expensesJson.add(jsonEncode(updatedExpense.toJson()));

      await prefs.setStringList('expenses', expensesJson);
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.find<MainBottomNavController>().backToHome();
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.green,
            leading: IconButton(
              onPressed: () {
                Get.find<MainBottomNavController>().backToHome();

              },
              icon:  const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title:  const Text(
              "Budget and Expenses' ",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 00),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildBudgetComparisonGraph(),
                ),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(

                    onPressed: () {
                      _showAddExpenseDialog(context);
                    },
                    child: const Text('Add Expense'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly Budget: ',style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        readOnly: true,
                        controller: _budgetController,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _monthlyBudget = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showUpdateBudgetDialog(context);
                      },
                      child: const Text('Update Budget'),
                    ),
                  ],
                ),
                SizedBox(height: 16,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetComparisonGraph() {
    double totalExpenses = _expenses.fold(0, (total, expense) => total + expense.amount);
    double remainingBudget = _monthlyBudget - totalExpenses;
    if (remainingBudget < 0) {
      remainingBudget = 0;
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.7,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: totalExpenses,
                        color: Colors.red,
                        width: 16,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      BarChartRodData(
                        toY: remainingBudget,
                        color: Colors.green,
                        width: 16,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                    showingTooltipIndicators: const [0, 1],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Monthly Budget',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Expenses:  ${totalExpenses.toStringAsFixed(2)} /-',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          'Remaining Budget:  ${remainingBudget.toStringAsFixed(2)} /-',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _expenses.length,
            itemBuilder: (context, index) {
              final expense = _expenses[index];
              return ListTile(
                shape: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tileColor: Colors.green.shade100,
                title:  Text(
                  'Amount: ${expense.amount.toStringAsFixed(2)} /-',
                  style: TextStyle(fontSize:18,color: Colors.red,fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.description,style: TextStyle(fontSize:18,color: Colors.black,fontWeight: FontWeight.bold)),
                    Text(
                      'Date: ${DateFormat('MM/dd/yyyy').format(expense.date)}',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,color: Colors.deepPurpleAccent,),
                      onPressed: () {
                        _showEditExpenseDialog(context, expense);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,color: Colors.red),
                      onPressed: () {
                        _deleteExpense(expense);
                      },
                    ),
                  ],
                ),
              );
            }, separatorBuilder: (BuildContext context, int index) {
              return const Divider(
                thickness: 2,
              );
          },
          ),
        ),
      ],
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final description = _descriptionController.text;
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                final newExpense = Expense(
                  description: description,
                  date: DateTime.now(),
                  amount: amount,
                );
                _saveExpense(newExpense);
                Navigator.of(context).pop();
                _descriptionController.clear();
                _amountController.clear();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditExpenseDialog(BuildContext context, Expense expense) {
    _descriptionController.text = expense.description;
    _amountController.text = expense.amount.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final description = _descriptionController.text;
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                final updatedExpense = Expense(
                  description: description,
                  date: DateTime.now(),
                  amount: amount,
                );
                _updateExpense(expense, updatedExpense);
                Navigator.of(context).pop();
                _descriptionController.clear();
                _amountController.clear();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateBudgetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Monthly Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monthly Budget'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final budget = double.tryParse(_budgetController.text) ?? 0.0;
                setState(() {
                  _monthlyBudget = budget;
                });
                _saveMonthlyBudget();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

