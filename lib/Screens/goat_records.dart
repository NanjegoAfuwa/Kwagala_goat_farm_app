import 'package:flutter/material.dart';

class GoatRecords extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Goat Records")),
      body: Center(
        child: Text(
          "List of farm goats will appear here",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
