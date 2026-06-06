import 'package:flutter/material.dart';

class AbilitiesDisplay extends StatelessWidget {
  final String abilities;

  const AbilitiesDisplay({super.key, required this.abilities});

  @override
  Widget build(BuildContext context) {
    // Split abilities by comma and trim whitespace
    final abilityList = abilities.split(',').map((a) => a.trim()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [Text(abilities)],
    );
  }
}
