import 'package:bazaarhelper_final/state_holder_controller.dart';
import 'package:bazaarhelper_final/ui/bazaar_information/bazaar_category.dart';
import 'package:bazaarhelper_final/ui/expenses_screen.dart';
import 'package:bazaarhelper_final/ui/objet_check_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final MainBottomNavController _bottomNavController = MainBottomNavController();

  @override
  void initState() {
    super.initState();
    // Set an initial value for the currentSelectedIndex
    _bottomNavController.currentSelectedIndex = 0;
  }
  final List<Widget> _screens = [
    HomeScreen(),
    ExpensesScreen(),
    ObjectCheck(),
    BazaarCategory()
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainBottomNavController>
      (builder: (controller) {
      return Scaffold(
          body: _screens[controller.currentSelectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentSelectedIndex,
            onTap: controller.changeScreen,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            elevation: 4,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.money_outlined), label: "Cost"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.document_scanner_outlined),
                  label: "Food Detect"),
              BottomNavigationBarItem(icon: Icon(Icons.shop), label: "Bazaar Info"),
            ],          ),);
    },
    );
  }
}




