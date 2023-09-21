import 'package:bazaarhelper_final/state_holder_controller.dart';
import 'package:bazaarhelper_final/ui/bazaar_information/fish_market.dart';
import 'package:bazaarhelper_final/ui/bazaar_information/super_shop.dart';
import 'package:bazaarhelper_final/ui/bazaar_information/vegetable_market.dart';
import 'package:bazaarhelper_final/ui/expenses_screen.dart';
import 'package:bazaarhelper_final/ui/home_info_cart.dart';
import 'package:bazaarhelper_final/widget/home_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

            title: Text(
              "Home",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                HomeSlider(),
                SizedBox(height: 40),
                Center(
                  child: Text(
                    "Get the Info...",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 25,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return HomeInfoCart(
                          title: "Budget",
                          image: AssetImage("assets/images/budget.jpg"),
                          onTap: () {
                            Get.to(()=>ExpensesScreen());
                          },
                        );
                      }
                      if (index == 1) {
                        return HomeInfoCart(
                          title: "Vegetable Bazar",
                          image: AssetImage("assets/images/vegetable_bazar.jpg"),
                          onTap: () {
                            Get.to(()=>VegetableMarket());
                          },
                        );
                      }
                      if (index == 2) {
                        return HomeInfoCart(
                          title: "Fish Market",
                          image: AssetImage("assets/images/fish_market.jpg"),
                          onTap: () {
                            Get.to(()=>FishMarket());
                          },
                        );
                      }
                      if (index == 3) {
                        return HomeInfoCart(
                          title: "Super Shop",
                          image: AssetImage("assets/images/super_shop.jpg"),
                          onTap: () {
                            Get.to(()=>SuperShop());
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

