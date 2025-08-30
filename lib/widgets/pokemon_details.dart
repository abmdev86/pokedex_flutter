import 'package:flutter/material.dart';
import 'package:pokedex_flutter/pokemon.dart';
import 'package:pokedex_flutter/utils/formatters.dart';
import 'package:pokedex_flutter/widgets/image_widget.dart';

class PokemonDetails extends StatelessWidget {
  const PokemonDetails({super.key, required this.pokemon});
  final Pokemon pokemon;
  String get _formattedID => formatId(pokemon.id);
  String get _imageUrl => officialArtworkUrl(pokemon.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_formattedID ${pokemon.name.toUpperCase()}'),
      ),
      body: SingleChildScrollView(
        child: Column(children: [ImageWidget(image: _imageUrl, height: 390)]),
      ),
    );
  }
}
