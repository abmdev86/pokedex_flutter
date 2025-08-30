import 'package:flutter/material.dart';

class StatTile extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(value.toString() + unit),
      ],
    );
  }
}
