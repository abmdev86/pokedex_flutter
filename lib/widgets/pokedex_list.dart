import 'package:flutter/material.dart';
import 'package:pokedex_flutter/widgets/pokedex_tile.dart';
import '../data/pokemon.dart';

class PokedexList extends StatelessWidget {
  const PokedexList({super.key, required this.pokemons, this.onTileTap});
  final List<Pokemon> pokemons;
  final void Function(Pokemon pokemon)? onTileTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: pokemons.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final p = pokemons[index];
        return PokedexTile(
          pokemon: p,
          onTap: onTileTap == null ? null : () => onTileTap!(p),
        );
      },
    );
  }
}
