

import 'package:bazaarhelper_final/state_holder_controller.dart';
import 'package:bazaarhelper_final/widget/MarketInfoTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/model.dart';
import '../bottom_nav_bar_screen.dart';

class SuperShop extends StatelessWidget {
  const SuperShop({super.key});

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
                Get.to(()=>BottomNavBar());
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title: Text(
              "Super Shop",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('supershop').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Show a loading indicator while data is loading
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final documents = snapshot.data!.docs;

              return ListView.builder(
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  final data = doc.data() as Map<String, dynamic>;

                  // Create a MarketInfo object from the Firestore data
                  final marketInfo = MarketInfo(
                    location: data['location'] ?? '',
                    offDay: data['off_day'] ?? '',
                    runHour: data['run_hour'] ?? '',
                    rushHour: data['rush_hour'] ?? '',
                  );

                  // Return a MarketInfoTile with the document ID as the title
                  return MarketInfoTile(
                    title: doc.id,
                    marketInfo: marketInfo,
                  );
                },
              );
            },
          ),
        )));
  }
}
