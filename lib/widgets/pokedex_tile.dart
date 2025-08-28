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

  // Picks the best image URL from sprites (official-artwork -> home -> front_default -> dream_world.svg*)
  // String? _bestImageUrl(Map<String, dynamic> s) {
  //   String? getIn(List<String> path) {
  //     dynamic cur = s;
  //     for (final key in path) {
  //       if (cur is Map && cur.containsKey(key)) {
  //         cur = cur[key];
  //       } else {
  //         return null;
  //       }
  //     }
  //     return cur is String && cur.isNotEmpty ? cur : null;
  //   }

  //   final official = getIn(['other', 'official-artwork', 'front_default']);
  //   if (official != null) return official;

  //   final home = getIn(['other', 'home', 'front_default']);
  //   if (home != null) return home;

  //   final front = getIn(['front_default']);
  //   if (front != null) return front;

  //   if (allowSvg) {
  //     final dream = getIn(['other', 'dream_world', 'front_default']); // .svg
  //     if (dream != null) return dream;
  //   }

  //   return null;
  // }

  // Widget _imageWidget(String? url) {
  //   const double size = 56;
  //   if (url == null) {
  //     return Image.asset(
  //       'assets/images/poke_placeholder.png',
  //       width: size,
  //       height: size,
  //       fit: BoxFit.contain,
  //     );
  //   }

  //   if (url.toLowerCase().endsWith('.svg')) {
  //     return SvgPicture.network(
  //       url,
  //       width: size,
  //       height: size,
  //       placeholderBuilder: (_) => const SizedBox(
  //         width: size,
  //         height: size,
  //         child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
  //       ),
  //       errorBuilder: (context, url, error) => Image.asset(
  //         'assets/images/poke_placeholder.png',
  //         width: 56,
  //         height: 56,
  //         fit: BoxFit.contain,
  //       ),
  //     );
  //   }
  //   return CachedNetworkImage(
  //     imageUrl: url,
  //     width: size,
  //     height: size,
  //     fit: BoxFit.contain,
  //     placeholder: (_, __) => const SizedBox(
  //       width: size,
  //       height: size,
  //       child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
  //     ),
  //     errorWidget: (_, __, ___) => Image.asset(
  //       'assets/images/poke_placeholder.png',
  //       width: size,
  //       height: size,
  //       fit: BoxFit.contain,
  //     ),
  //   );
  // }

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
