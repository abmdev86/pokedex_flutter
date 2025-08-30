import 'package:flutter/material.dart';
import 'package:pokedex_flutter/widgets/pokemon_details.dart';

import 'data/pokemon.dart';
import 'widgets/pokedex_tile.dart';

class PokedexPage extends StatefulWidget {
  const PokedexPage({super.key});

  @override
  State<PokedexPage> createState() => _PokedexPageState();
}

class _PokedexPageState extends State<PokedexPage> {
  static const _limit = 20;

  final _scroll = ScrollController();
  final List<Pokemon> _pokemons = [];
  int _offset = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPage();

    _scroll.addListener(() {
      // When we’re close to the bottom, try to load the next page
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        _loadPage();
      }
    });
  }

  Future<void> _loadPage({bool refresh = false}) async {
    if (_isLoading) return;
    if (!_hasMore && !refresh) return;

    setState(() {
      _isLoading = true;
      if (refresh) _error = null;
    });

    try {
      if (refresh) {
        _offset = 0;
        _hasMore = true;
      }

      final page = await fetchPokeList(limit: _limit, offset: _offset);

      setState(() {
        if (refresh) _pokemons.clear();
        _pokemons.addAll(page);
        _offset += _limit;
        _hasMore = page.length == _limit; // if fewer than limit → no more pages
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() => _loadPage(refresh: true);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _error != null && _pokemons.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Oops: $_error'),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: _loadPage,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(vertical: 8),
                // +1 for the loader row when there’s more to load
                itemCount: _pokemons.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _pokemons.length) {
                    final p = _pokemons[index];
                    return Column(
                      children: [
                        PokedexTile(
                          pokemon: p,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => PokemonDetails(pokemon: p),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 72),
                      ],
                    );
                  }

                  // Loader row (last item)
                  // Trigger another load once this row gets built
                  if (!_isLoading) {
                    // small microtask to avoid setState during build
                    Future.microtask(_loadPage);
                  }
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
      ),
    );
  }
}
