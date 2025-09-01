import 'package:flutter/material.dart';
import 'package:pokedex_flutter/data/pokemon.dart';

import 'stat_tile.dart';

class StatDisplay extends StatelessWidget {
  final Pokemon pokemon;

  const StatDisplay({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StatTile(label: 'Base Experience', value: pokemon.baseExp),
        StatTile(label: 'Height', value: pokemon.height, unit: 'm'),
        StatTile(label: 'Weight', value: pokemon.weight, unit: 'kg'),
      ],
    );
  }
}
