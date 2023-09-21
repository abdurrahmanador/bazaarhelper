import 'package:bazaarhelper_final/widget/MarketInfoTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/model.dart';

class BazaarInfo extends StatefulWidget {
  const BazaarInfo({super.key});

  @override
  State<BazaarInfo> createState() => _BazaarInfoState();
}

class _BazaarInfoState extends State<BazaarInfo> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('supershop').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        List<MarketInfoTile> marketInfoTiles = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final marketInfo = MarketInfo(
            location: data['location'],
            offDay: data['off_day'],
            runHour: data['run_hour'],
            rushHour: data['rush_hour'],
          );
          return MarketInfoTile(title: doc.id, marketInfo: marketInfo);
        }).toList();

        return ListView(
          children: marketInfoTiles,
        );
      },
    );
  }
}
