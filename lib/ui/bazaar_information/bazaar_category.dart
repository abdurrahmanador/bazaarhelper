import 'package:bazaarhelper_final/state_holder_controller.dart';
import 'package:bazaarhelper_final/ui/bazaar_information/super_shop.dart';
import 'package:bazaarhelper_final/ui/bazaar_information/vegetable_market.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bottom_nav_bar_screen.dart';
import 'fish_market.dart';

class BazaarCategory extends StatefulWidget {
   BazaarCategory({super.key});

  @override
  State<BazaarCategory> createState() => _BazaarCategoryState();
}

class _BazaarCategoryState extends State<BazaarCategory> {
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
                Get.offAll(()=>BottomNavBar());
              },
              icon:  const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title:  const Text(
              "Bazaar ",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(4.0),
            child: ListView?.separated(
              itemCount: 3,
              separatorBuilder: (context, index) =>  const Divider(thickness: 2,),
              itemBuilder: (context, index) {
                String title = "";
                VoidCallback? onTap;
                String imagePath = "";

                if (index == 0) {
                  title = "Vegetable Market";
                  imagePath = "assets/images/kb.png";
                  onTap = () {
                    Get.to((()=> const VegetableMarket()));
                  };
                } else if (index == 1) {
                  title = "Fish Market";
                  imagePath = "assets/images/mb.png";
                  onTap = () {
                    Get.to((()=> const FishMarket()));
                  };
                } else if (index == 2) {
                  title = "Supershop";
                  imagePath = "assets/images/sb.png";
                  onTap = () {
                    Get.to((()=> const SuperShop()));

                  };
                }
                onTap ??= () {};
                return CustomListTile(title: title, imagePath: imagePath, onTap: onTap);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

   CustomListTile({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16)
      ),
      contentPadding:  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(
          imagePath,
          fit: BoxFit.fill,
        ),
      ),
      trailing:  const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black,
      ),
      onTap: onTap,
    );
  }
}






// import 'package:bazaarhelper_final/state_holder_controller.dart';
// import 'package:bazaarhelper_final/ui/bazaar_information/super_shop.dart';
// import 'package:bazaarhelper_final/ui/bazaar_information/vegetable_market.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../bottom_nav_bar_screen.dart';
// import 'fish_market.dart';
//
// class BazaarCategory extends StatefulWidget {
//    BazaarCategory({super.key});
//
//   @override
//   State<BazaarCategory> createState() => _BazaarCategoryState();
// }
//
// class _BazaarCategoryState extends State<BazaarCategory> {
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Get.find<MainBottomNavController>().backToHome();
//         return false;
//       },
//       child: SafeArea(
//         child: Scaffold(
//           appBar: AppBar(
//             elevation: 0,
//             backgroundColor: Colors.green,
//             leading: IconButton(
//               onPressed: () {
//                 Get.to(()=>BottomNavBar());
//               },
//               icon:  Icon(
//                 Icons.arrow_back,
//                 color: Colors.white,
//               ),
//             ),
//             title: Text(
//               "Bazaar ",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//           body: ListView.separated(
//             itemCount: 3, // Number of items
//             separatorBuilder: (context, index) => Divider(), // Add dividers
//             itemBuilder: (context, index) {
//               String title = ""; // Provide initial value
//               VoidCallback? onTap;
//
//               if (index == 0) {
//                 title = "Vegetable Market";
//                 onTap = () {
//                   // Navigate or perform action
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => VegetableMarket(),
//                     ),
//                   );
//                 };
//               } else if (index == 1) {
//                 title = "Fish Market";
//                 onTap = () {
//                   // Navigate or perform action
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => FishMarket(),
//                     ),
//                   );
//                 };
//               } else if (index == 2) {
//                 title = "Supershop";
//                 onTap = () {
//                   // Navigate or perform action
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => SuperShop(),
//                     ),
//                   );
//                 };
//               }
//               onTap ??= () {};
//               return CustomListTile(title: title, onTap: onTap);
//
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class CustomListTile extends StatelessWidget {
//   final String title;
//   final VoidCallback onTap;
//
//   CustomListTile({required this.title, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       title: AspectRatio(
//         aspectRatio: 16 / 9, // 16:9 aspect ratio
//         child: Image.network(
//           'https://c.pxhere.com/photos/2a/b6/photo-114366.jpg!d', // Replace with your image URL
//           fit: BoxFit.cover, // Adjust image fit as needed
//         ),
//       ),
//       trailing: Icon(
//         Icons.arrow_forward_ios,
//         color: Colors.blue,
//       ),
//       onTap: onTap,
//     );
//   }
// }
