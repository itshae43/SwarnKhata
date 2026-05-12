import 'package:flutter/material.dart';

class PartiesScreen extends StatelessWidget {
  const PartiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Hello', style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          Text('Parties Screen', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
