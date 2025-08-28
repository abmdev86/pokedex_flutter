import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pokedex_flutter/pokemon.dart';

import '../utils/formatters.dart';

class PokedexTile extends StatelessWidget {
  final VoidCallback? onTap;

  // final bool allowSvg;
  final Pokemon pokemon;

  const PokedexTile({super.key, required this.pokemon, this.onTap});

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String get _formattedID => '#${pokemon.id.toString().padLeft(3, '0')}';
  String get _imgUrl => officialArtworkUrl(pokemon.id);

  @override
  Widget build(BuildContext context) {
    const double size = 56;

    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: _imgUrl,
          height: size,
          width: size,
          fit: BoxFit.contain,
          placeholder: (_, __) => const SizedBox(
            width: size,
            height: size,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (_, __, ___) => Image.asset(
            'assets/images/poke_placeholder.png',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ),
      title: Text(
        _capitalize('$_formattedID ${pokemon.name}'),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
