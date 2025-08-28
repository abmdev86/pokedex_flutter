import 'package:flutter/material.dart';
import 'package:pokedex_flutter/pokemon.dart';

class PokemonDetails extends StatelessWidget {
  const PokemonDetails({super.key, required this.pokemon});
  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pokemon.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(pokemon.name),
      ),
    );
  }
}
