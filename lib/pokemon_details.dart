import 'package:flutter/material.dart';
import 'package:pokedex_flutter/data/pokeapi.dart';
import 'package:pokedex_flutter/data/pokemon.dart';
import 'package:pokedex_flutter/utils/formatters.dart';
import 'package:pokedex_flutter/widgets/image_widget.dart';
import 'package:pokedex_flutter/widgets/stat_tile.dart';
import 'package:pokedex_flutter/widgets/types_display.dart';

class PokemonDetails extends StatefulWidget {
  const PokemonDetails({super.key, required this.pokemon});
  final Pokemon pokemon;

  @override
  State<PokemonDetails> createState() => _PokemonDetailsState();
}

class _PokemonDetailsState extends State<PokemonDetails> {
  String get _formattedID => formatId(widget.pokemon.id);

  String get _imageUrl => officialArtworkUrl(widget.pokemon.id);
  late Future<Pokemon> _futurePokemon;

  @override
  void initState() {
    super.initState();
    _futurePokemon = fetchPokemon(widget.pokemon.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${widget.pokemon.name.toUpperCase()} $_formattedID',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ),
      body: FutureBuilder<Pokemon>(
        future: _futurePokemon,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final pokemon = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                TypesDisplay(types: pokemon.listTypes),
                Center(child: ImageWidget(image: _imageUrl, height: 390)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StatTile(label: 'Base Experience', value: pokemon.baseExp),
                    StatTile(label: 'Height', value: pokemon.height, unit: 'm'),
                    StatTile(
                      label: 'Weight',
                      value: pokemon.weight,
                      unit: 'kg',
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      children: [Text('Abilities: ${pokemon.listAbilities}')],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

              
                // Add more details here using `pokemon`
        
          
        
      
   