import 'package:bazaarhelper_final/state_holder_controller.dart';
import 'package:bazaarhelper_final/ui/bottom_nav_bar_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widget/MarketInfoTile.dart';
import '../../model/model.dart';

class VegetableMarket extends StatefulWidget {
  const VegetableMarket({super.key});

  @override
  _VegetableMarketState createState() => _VegetableMarketState();
}

class _VegetableMarketState extends State<VegetableMarket> {
  final TextEditingController _searchController = TextEditingController();
  List<MarketInfo> _data = [];
  List<MarketInfo> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _fetchDataFromFirestore();
  }

  void _fetchDataFromFirestore() async {
    final querySnapshot =
    await FirebaseFirestore.instance.collection('vegetable_market').get();

    setState(() {
      _data = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MarketInfo(
          location: data['location'] ?? '',
          offDay: data['off_day'] ?? '',
          runHour: data['run_time'] ?? '',
          rushHour: data['rush_time'] ?? '',
        );
      }).toList();
      _filteredData = _data; // Initialize filtered data with all data
    });
  }

  void _performSearch(String query) {
    // Perform a basic case-insensitive search
    final lowercaseQuery = query.toLowerCase();
    final filteredData = _data.where((marketInfo) {
      return marketInfo.location.toLowerCase().contains(lowercaseQuery) ||
          marketInfo.offDay.toLowerCase().contains(lowercaseQuery) ||
          marketInfo.runHour.toLowerCase().contains(lowercaseQuery) ||
          marketInfo.rushHour.toLowerCase().contains(lowercaseQuery);
    }).toList();

    setState(() {
      _filteredData = filteredData;
    });
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
                Get.to(() => BottomNavBar());
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title: Text(
              "Vegetable Market",
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    _performSearch(value);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredData.length,
                  itemBuilder: (context, index) {
                    final marketInfo = _filteredData[index];

                    // Use the MarketInfoTile widget for consistent styling
                    return MarketInfoTile(
                      title: marketInfo.location,
                      marketInfo: marketInfo,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
