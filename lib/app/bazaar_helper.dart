import 'package:bazaarhelper_final/ui/bazaar_information/bazaar_info.dart';
import 'package:bazaarhelper_final/ui/bottom_nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../state_holder_binders.dart';
import '../ui/bazaar_information/bazaar_category.dart';
import '../ui/splash_screen.dart';

class BazaarHelper extends StatefulWidget {
  const BazaarHelper({super.key});

  @override
  State<BazaarHelper> createState() => _BazaarHelperState();
}

class _BazaarHelperState extends State<BazaarHelper> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: StateHolderBinders(),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.all(16),
          fillColor: Colors.white70,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder:  OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
            enabledBorder:  OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          disabledBorder:  OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green
          )
        ),
      ),
    );
  }
}
