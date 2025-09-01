import 'package:flutter/material.dart';

class TypesDisplay extends StatelessWidget {
  final String types;

  const TypesDisplay({super.key, required this.types});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          types.toUpperCase(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
