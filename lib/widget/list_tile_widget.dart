import 'package:flutter/material.dart';

class ListTiles extends StatelessWidget {
  const ListTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: ListTile(
          title: Text("Vegetable Market",style: TextStyle(
            fontSize: 24,
          ),),
        ),
      ),
    );
  }
}
