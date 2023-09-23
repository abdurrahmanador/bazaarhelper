
import 'package:bazaarhelper_final/widget/screen_background.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bottom_nav_bar_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NavigationToBottomNavScreen();

  }

  void NavigationToBottomNavScreen() {
    Future
        .delayed(Duration(seconds: 2))
        .then((_){
          Get.offAll(()=>const BottomNavBar());
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ScreenBackground(
            child: Center(
              child: Image.asset("assets/images/bazaar_helpeer.png",fit: BoxFit.cover,width: 150,height: 150,)

              ),

            )
    );
  }
}