import 'package:flutter/material.dart';
import 'package:pokedex_flutter/widgets/pokedex_tile.dart';
import '../pokemon.dart';

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

// class _PokedexListState extends State<PokedexList> {
//   final _scrollController = ScrollController();
//   final List<Pokemon> _items = [];
//   int _pageIndex = 0;
//   final int _limit = 20;
//   bool _isLoading = false;
//   bool _hasMore = true;

//   // late Future<Pokemon> futurePokemon;
//   late Future<List<Pokemon>> futureList;

//   @override
//   void initState() {
//     super.initState();
//     _loadMore();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (!_scrollController.hasClients || _isLoading || !_hasMore) return;

//     // load next page within 200 px of the bottom
//     final threshold = 200.0;
//     final position = _scrollController.position;
//     if (position.pixels >= position.maxScrollExtent - threshold) {
//       _loadMore();
//     }
//   }

//   Future<void> _loadMore({bool forceRefresh = false}) async {
//     if (_isLoading || !_hasMore) return;
//     setState(() => _isLoading = true);
//     try {
//       final offset = _pageIndex * _limit;
//       final newPage = await fetchPokeList(
//         limit: _limit,
//         offset: offset,
//         forceRefresh: forceRefresh,
//       );
//       if (!mounted) return;

//       setState(() {
//         _items.addAll(newPage);
//         _pageIndex += 1;
//         if (newPage.length < _limit) _hasMore = false;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _refresh() async {
//     // Optional pull-to-refresh: clear and reload from page 0
//     setState(() {
//       _items.clear();
//       _pageIndex = 0;
//       _hasMore = true;
//     });
//     await _loadMore(forceRefresh: true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: _refresh,
//       child: ListView.separated(
//         controller: _scrollController,
//         itemCount: _items.length + (_hasMore ? 1 : 0),
//         itemBuilder: (context, index) {
//          return PokedexTile(pokemon: p)

//         },
//       ),
//     );
//   }
// }
