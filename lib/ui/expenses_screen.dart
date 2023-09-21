import 'dart:convert';
import 'package:bazaarhelper_final/model/expences.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


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

  @override
  void initState() {
    super.initState();
    _loadMonthlyBudget();
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.green,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title: const Text(
              'Budget and Expenses',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 00),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FutureBuilder<List<Expense>>(
                    future: _getExpenses(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final expenses = snapshot.data ?? [];

                      return _buildBudgetComparisonGraph(expenses);
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _showAddExpenseDialog(context);
                  },
                  child: const Text('Add Expense'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly Budget: '),
                    SizedBox(
                      width: 100,
                      child: TextField(
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Expense>> _getExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> expensesJson = prefs.getStringList('expenses') ?? [];
    return expensesJson.map((expenseJson) {
      return Expense.fromJson(Map<String, dynamic>.from(jsonDecode(expenseJson)));
    }).toList();
  }

  Widget _buildBudgetComparisonGraph(List<Expense> expenses) {
    double totalExpenses = expenses.fold(0, (total, expense) => total + expense.amount);
    double remainingBudget = _monthlyBudget - totalExpenses;
    if (remainingBudget < 0) {
      remainingBudget = 0;
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.7,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
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
                      borderRadius:  BorderRadius.circular(8),
                    ),
                    BarChartRodData(
                      toY: remainingBudget,
                      color: Colors.green,
                      width: 16,
                      borderRadius:  BorderRadius.circular(8),
                    ),
                  ],
                  showingTooltipIndicators: const [0, 1],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ListTile(
                tileColor: Colors.green.shade100,
                title: Text(expense.description),
                subtitle: Text('Amount: ${expense.amount.toStringAsFixed(2)} /-'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditExpenseDialog(context, expense);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteExpense(expense);
                      },
                    ),
                  ],
                ),
              );
            }, separatorBuilder: (BuildContext context, int index) {
            return const Divider(thickness: 5,);
          },
          ),
        ),
      ],
    );
  }

  void _deleteExpense(Expense expense) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> expensesJson = prefs.getStringList('expenses') ?? [];
    expensesJson.removeWhere((expenseJson) {
      final expenseData = jsonDecode(expenseJson);
      return Expense.fromJson(expenseData).date == expense.date;
    });
    await prefs.setStringList('expenses', expensesJson);
    setState(() {});
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

  void _saveExpense(Expense expense) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> expensesJson = prefs.getStringList('expenses') ?? [];
    expensesJson.add(jsonEncode(expense.toJson()));
    await prefs.setStringList('expenses', expensesJson);
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
              SizedBox(height:16),
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

  void _updateExpense(Expense oldExpense, Expense updatedExpense) async {
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
      setState(() {});
    }
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


// import 'package:bazaarhelper_final/model/expences.dart';
// import 'package:bazaarhelper_final/state_holder_controller.dart';
// import 'package:bazaarhelper_final/ui/bottom_nav_bar_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../share_preferences_helper.dart';
//
// class ExpensesScreen extends StatefulWidget {
//   @override
//   _ExpensesScreenState createState() => _ExpensesScreenState();
// }
//
// class _ExpensesScreenState extends State<ExpensesScreen> {
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: ()async{
//         Get.find<MainBottomNavController>().backToHome();
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Colors.green,
//           leading: IconButton(
//             onPressed: () {
//               Get.to(()=>BottomNavBar());
//             },
//             icon: const Icon(
//               Icons.arrow_back,
//               color: Colors.white,
//             ),
//           ),
//           title: Text('Budget and Expenses',style: TextStyle(color: Colors.white)),
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: ElevatedButton(
//                 onPressed: () {
//                   _showAddExpenseDialog(context);
//                 },
//                 child: Text('Add Expense'),
//               ),
//             ),
//             Expanded(
//               child: FutureBuilder<List<Expense>>(
//                 future: SharedPreferencesHelper.getExpenses(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }
//                   final expenses = snapshot.data ?? [];
//
//                   return ListView.builder(
//                     itemCount: expenses.length,
//                     itemBuilder: (context, index) {
//                       final expense = expenses[index];
//                       return Card(
//                         color: Colors.green.shade100,
//                         elevation: 2.0,
//                         margin: EdgeInsets.all(8.0),
//                         child: ListTile(
//                           leading: Icon(Icons.money),
//                           title: Text("${expense.description}\nExpenses: ${expense.amount.toStringAsFixed(2)}/-"),
//                           subtitle: Text(
//                             '${expense.date}',
//                           ),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: Icon(Icons.edit),
//                                 onPressed: () {
//                                   _showEditExpenseDialog(context, expense);
//                                 },
//                               ),
//                               IconButton(
//                                 icon: Icon(Icons.delete),
//                                 onPressed: () {
//                                   _showDeleteConfirmationDialog(context, expense);
//                                 },
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showAddExpenseDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Add Expense'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               TextField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(labelText: 'Description'),
//               ),
//               SizedBox(height: 16,),
//               TextField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: 'Amount'),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Save'),
//               onPressed: () {
//                 final description = _descriptionController.text;
//                 final amount =
//                     double.tryParse(_amountController.text) ?? 0.0;
//                 final newExpense = Expense(
//                   description: description,
//                   date: DateTime.now(),
//                   amount: amount,
//                 );
//                 SharedPreferencesHelper.saveExpense(newExpense);
//                 Navigator.of(context).pop();
//                 _descriptionController.clear();
//                 _amountController.clear();
//                 setState(() {});
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showEditExpenseDialog(BuildContext context, Expense expense) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Edit Expense'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               TextField(
//                 controller: _descriptionController..text = expense.description,
//                 decoration: InputDecoration(labelText: 'Description'),
//               ),
//               TextField(
//                 controller: _amountController..text = expense.amount.toString(),
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(labelText: 'Amount'),
//               ),
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Save'),
//               onPressed: () {
//                 final description = _descriptionController.text;
//                 final amount =
//                     double.tryParse(_amountController.text) ?? 0.0;
//                 final updatedExpense = Expense(
//                   description: description,
//                   date: DateTime.now(),
//                   amount: amount,
//                 );
//                 SharedPreferencesHelper.updateExpense(expense, updatedExpense);
//                 Navigator.of(context).pop();
//                 _descriptionController.clear();
//                 _amountController.clear();
//                 setState(() {});
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showDeleteConfirmationDialog(BuildContext context, Expense expense) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Confirm Delete'),
//           content: Text('Are you sure you want to delete this expense?'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Delete'),
//               onPressed: () {
//                 SharedPreferencesHelper.deleteExpense(expense);
//                 Navigator.of(context).pop();
//                 setState(() {});
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
