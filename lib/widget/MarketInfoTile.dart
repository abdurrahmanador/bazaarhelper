import 'package:flutter/material.dart';

import '../model/model.dart';

class MarketInfoTile extends StatelessWidget {
  final String title; // Document ID
  final MarketInfo marketInfo;

  MarketInfoTile({Key? key, required this.title, required this.marketInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.amber.shade500,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          title: Text(
            'Location: ${marketInfo.location}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18, // Increase font size
              color: Colors.green, // Change text color
            ),
          ),
          leading: Icon(
            Icons.shopping_cart,
            size: 36, // Increase icon size
            color: Colors.amber, // Change icon color
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Off Day: ${marketInfo.offDay}',
                style: TextStyle(
                  fontSize: 16, // Adjust font size
                ),
              ),
              Text(
                'Run Time: ${marketInfo.runHour}',
                style: TextStyle(
                  fontSize: 16, // Adjust font size
                ),
              ),
              Text(
                'Rush Time: ${marketInfo.rushHour}',
                style: TextStyle(
                  fontSize: 16, // Adjust font size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
